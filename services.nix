{ config, pkgs, ... }:

{
  services.haproxy.enable = true;
  services.haproxy.config = ''
    global
      log /dev/log local0
      log /dev/log local1 notice
      chroot /var/lib/haproxy
      user haproxy
      group haproxy
    defaults
      option forwardfor
      option http-server-close
    frontend www-http
      mode http
      bind :80
      acl letsencrypt-acl path_beg /.well-known/acme-challenge/
      acl grafana-acl hdr(host) -i grafana.tars.nyanlout.re
      acl emby-acl hdr(host) -i emby.tars.nyanlout.re
      acl radarr-acl hdr(host) -i radarr.tars.nyanlout.re
      use_backend letsencrypt-backend if letsencrypt-acl
      use_backend grafana-backend if grafana-acl
      use_backend emby-backend if emby-acl
      use_backend radarr-backend if radarr-acl
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
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "acme" = {
      listen = [ { addr = "127.0.0.1"; port = 54321; } ];
      locations = { "/" = { root = "/var/www/challenges"; }; };
    };
  };

#  security.acme.certs = {
#    "grafana.tars.nyanlout.re" = {
#      user = "nginx";
#      webroot = "/var/www/challenges";
#      email = "paul@nyanlout.re";
#    };
#  };
#  security.acme.directory = "/var/lib/acme";

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

  services.radarr.enable = true;

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
