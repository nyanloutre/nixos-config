{ config, pkgs, ... }:

{
  services.haproxy.enable = true;
  services.haproxy.config = ''
    defaults
      log /dev/log local0
      log /dev/log local1 notice
      chroot /var/lib/haproxy
      user haproxy
      group haproxy
      option forwardfor
      option http-server-close
    frontend www-http
      bind tars.nyanlout.re:80
      reqadd X-Forwarded-Proto:\ http
      default_backend www-backend
    frontend www-https
      bind tars.nyanlout.re:443 ssl crt /var/lib/acme/tars.nyanlout.re/fullchain.pem
      reqadd X-Forwarded-Proto:\ https
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      use_backend letsencrypt-backend if letsencrypt-acl
      default_backend www-backend
    backend www-backend
      redirect scheme https if !{ ssl_fc }
      server www-1 127.0.0.1:3000 check
    backend letsencrypt-backend
      server letsencrypt 127.0.0.1:54321
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges" }; };
    };
  };

  security.acme.certs = {
    "tars.nyanlout.re" = {
      webroot = "/var/www/challenges";
      email = "paul@nyanlout.re";
    };
  };

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
  services.grafana.addr = "0.0.0.0";
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

  networking.firewall.allowedTCPPorts = [
    80 443 # HAProxy
    3000 # Grafana
    8096 # Emby
    111 2049 4000 4001 4002 # NFS
    3483 9000 # Slimserver
    8384 # Syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
    3483 # Slimserver
  ];
}
