{ config, lib, pkgs, ... }:

with lib;

let

  haproxy_backends = {
    grafana = { ip = "127.0.0.1"; port = 3000; auth = false; };
    emby = { ip = "127.0.0.1"; port = 8096; auth = false; };
    radarr = { ip = "127.0.0.1"; port = 7878; auth = false; };
    sonarr = { ip = "127.0.0.1"; port = 8989; auth = false; };
    transmission = { ip = "127.0.0.1"; port = 9091; auth = true; };
    syncthing = { ip = "127.0.0.1"; port = 8384; auth = true; };
  };

  domaine = "tars.nyanlout.re";

in

{
  imports = [
    ./mail-server.nix
  ];

  services.haproxy.enable = true;

  services.haproxy.config = ''
    global
      log /dev/log local0
      log /dev/log local1 notice
      user haproxy
      group haproxy
      ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
      ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
      ssl-default-server-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
      ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
    defaults
      option forwardfor
      option http-server-close
      timeout client 10s
      timeout connect 4s
      timeout server 30s
    userlist LOUTRE
      user paul password $6$6rDdCtzSVsAwB6KP$V8bR7KP7FSL2BSEh6n3op6iYhAnsVSPI2Ar3H6MwKrJ/lZRzUI8a0TwVBD2JPnAntUhLpmRudrvdq2Ls2odAy.
    frontend public
      bind :::80 v4v6
      bind :::443 v4v6 ssl crt /var/lib/acme/${domaine}/full.pem
      mode http
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
      use_backend letsencrypt-backend if letsencrypt-acl

    ${concatStrings (
      mapAttrsToList (name: value:
        "
  acl ${name}-acl hdr(host) -i ${name}.${domaine}
  use_backend ${name}-backend if ${name}-acl
        ") haproxy_backends)}

    backend letsencrypt-backend
      mode http
      server letsencrypt 127.0.0.1:54321

    ${concatStrings (
      mapAttrsToList (name: value:
        ''

backend ${name}-backend
  mode http
  server ${name} ${value.ip}:${toString value.port}
  ${(if value.auth then (
    "
  acl AuthOK_LOUTRE http_auth(LOUTRE)
  http-request auth realm LOUTRE if !AuthOK_LOUTRE
    ") else "")}
        ''
        ) haproxy_backends)}
    '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
  };

  security.acme.certs = {
    ${domaine} = {
      extraDomains = mapAttrs' (name: value:
        nameValuePair ("${name}.${domaine}") (null)
      ) haproxy_backends;
      webroot = "/var/www/challenges/";
      email = "paul@nyanlout.re";
      user = "haproxy";
      group = "haproxy";
      postRun = "systemctl reload haproxy";
    };
  };
  security.acme.directory = "/var/lib/acme";

  services.influxdb.enable = true;
  services.influxdb.dataDir = "/var/db/influxdb";

  services.telegraf.enable = true;
  services.telegraf.extraConfig = {
    inputs = {
      zfs = { poolMetrics = true; };
      net = { interfaces = [ "eno1" "eno2" "eno3" "eno4" ]; };
      netstat = {};
      cpu = { totalcpu = true; };
      kernel = {};
      mem = {};
      processes = {};
      system = {};
      disk = {};
      ipmi_sensor = { path = "${pkgs.ipmitool}/bin/ipmitool"; };
    };
    outputs = {
      influxdb = { database = "telegraf"; urls = [ "http://localhost:8086" ]; };
    };
  };

  services.udev.extraRules = ''
    KERNEL=="ipmi*", MODE="660", OWNER="telegraf"
  '';

  services.grafana.enable = true;
  services.grafana.addr = "127.0.0.1";
  services.grafana.dataDir = "/var/lib/grafana";

  services.emby.enable = true;
  services.emby.dataDir = "/var/lib/emby/ProgramData-Server";

  services.slimserver.enable = true;
  services.slimserver.dataDir = "/var/lib/slimserver";

  services.syncthing.enable = true;
  services.syncthing.dataDir = "/var/lib/syncthing";
  services.syncthing.openDefaultPorts = true;
  
#  services.nfs.server = {
#    enable = true;
#    exports = ''
#      /exports/steam  192.168.1.0/24(rw,no_root_squash)
#    '';
#    statdPort = 4000;
#    lockdPort = 4001;
#    mountdPort = 4002;
#  };

  services.transmission.enable = true;
  services.transmission.home = "/var/lib/transmission";
  services.transmission.settings = {
    rpc-bind-address = "127.0.0.1";
    rpc-host-whitelist = "*";
    rpc-whitelist-enabled = false;
  };

  services.radarr.enable = true;

  services.sonarr.enable = true;

  services.murmur.enable = true;
  services.murmur.bandwidth = 128000;
  services.murmur.imgMsgLength = 0;
  services.murmur.textMsgLength = 0;

  services.mailserver.enable = true;
  services.mailserver.domaine = domaine;

  networking.firewall.allowedTCPPorts = [
    80 443 # HAProxy
#    111 2049 4000 4001 4002 # NFS
    3483 9000 9090 # Slimserver
    51413 # Transmission
  ];
  networking.firewall.allowedUDPPorts = [
#    111 2049 4000 4001 4002 # NFS
    3483 # Slimserver
    51413 # Transmission
  ];
}
