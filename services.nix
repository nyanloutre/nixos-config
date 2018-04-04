{ config, pkgs, ... }:

{
  services.haproxy.enable = true;
  services.haproxy.config = ''
    global
      log /dev/log local0
      log /dev/log local1 notice
      user haproxy
      group haproxy
    defaults
      option forwardfor
      option http-server-close
    userlist LOUTRE
      user paul password $6$6rDdCtzSVsAwB6KP$V8bR7KP7FSL2BSEh6n3op6iYhAnsVSPI2Ar3H6MwKrJ/lZRzUI8a0TwVBD2JPnAntUhLpmRudrvdq2Ls2odAy.
    frontend public
      bind :80
      bind :443 ssl crt /var/lib/acme/tars.nyanlout.re/full.pem
      mode http
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      use_backend letsencrypt-backend if letsencrypt-acl
      redirect scheme https if !{ ssl_fc } !letsencrypt-acl
      acl grafana-acl hdr(host) -i grafana.tars.nyanlout.re
      acl emby-acl hdr(host) -i emby.tars.nyanlout.re
      acl radarr-acl hdr(host) -i radarr.tars.nyanlout.re
      acl transmission-acl hdr(host) -i transmission.tars.nyanlout.re
      use_backend grafana-backend if grafana-acl
      use_backend emby-backend if emby-acl
      use_backend radarr-backend if radarr-acl
      use_backend transmission-backend if transmission-acl
    backend letsencrypt-backend
      mode http
      server letsencrypt 127.0.0.1:54321
    backend grafana-backend
      mode http
      server grafana 127.0.0.1:3000 check
    backend emby-backend
      mode http
      server emby 127.0.0.1:8096 check
    backend radarr-backend
      mode http
      server radarr 127.0.0.1:7878 check
    backend transmission-backend
      mode http
      acl AuthOK_LOUTRE http_auth(LOUTRE)
      http-request auth realm LOUTRE if !AuthOK_LOUTRE
      server radarr 127.0.0.1:9091 check
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
  };

  security.acme.certs = {
    "tars.nyanlout.re" = {
      extraDomains = {
        "grafana.tars.nyanlout.re" = null;
        "emby.tars.nyanlout.re" = null;
        "radarr.tars.nyanlout.re" = null;
        "transmission.tars.nyanlout.re" = null;
      };
      webroot = "/var/www/challenges/";
      email = "paul@nyanlout.re";
      user = "haproxy";
      group = "haproxy";
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
    };
    outputs = {
      influxdb = { database = "telegraf"; urls = [ "http://localhost:8086" ]; };
    };
  };

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
  
  systemd = {
    services.duplicati = {
      description = "Duplicati backup";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Slice = "machine.slice";
        ExecStart = "${pkgs.rkt}/bin/rkt --insecure-options=image --pull-policy=update run --volume volume-config,kind=host,source=/var/lib/duplicati --volume volume-source,kind=host,source=/mnt/medias,readOnly=true --port 8200-tcp:8200 --dns 8.8.8.8 --dns 8.8.4.4 docker://linuxserver/duplicati";
        ExecStopPost = "${pkgs.rkt}/bin/rkt gc --mark-only";
        KillMode = "mixed";
        Restart = "on-failure";
	RestartSec = 3;
      };
      enable = true;
    };
  };
  
  services.nfs.server = {
    enable = true;
    exports = ''
      /exports/steam  192.168.1.0/24(rw,no_root_squash)
    '';
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
  };

  services.transmission.enable = true;
  services.transmission.home = "/var/lib/transmission";
  services.transmission.settings = {
    rpc-bind-address = "127.0.0.1";
    rpc-host-whitelist = "*";
    rpc-whitelist-enabled = false;
  };

  services.radarr.enable = true;

  services.murmur.enable = true;
  services.murmur.bandwidth = 128000;
  services.murmur.imgMsgLength = 0;
  services.murmur.textMsgLength = 0;

  networking.firewall.allowedTCPPorts = [
    80 443 # HAProxy
    111 2049 4000 4001 4002 # NFS
    3483 9000 # Slimserver
    8384 # Syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
    3483 # Slimserver
  ];
}
