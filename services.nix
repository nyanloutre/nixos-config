{ config, lib, pkgs, ... }:

with lib;

let
  domaine = "tars.nyanlout.re";
in

{
  imports = [
    ./haproxy-acme.nix
    ./mail-server.nix
  ];

  services.haproxy-acme.enable = true;
  services.haproxy-acme.domaine = domaine;
  services.haproxy-acme.services = {
    grafana = { ip = "127.0.0.1"; port = 3000; auth = false; };
    emby = { ip = "127.0.0.1"; port = 8096; auth = false; };
    radarr = { ip = "127.0.0.1"; port = 7878; auth = false; };
    sonarr = { ip = "127.0.0.1"; port = 8989; auth = false; };
    transmission = { ip = "127.0.0.1"; port = 9091; auth = true; };
    syncthing = { ip = "127.0.0.1"; port = 8384; auth = true; };
    jackett = { ip = "127.0.0.1"; port = 9117; auth = true; };
  };

  services.mailserver.enable = true;
  services.mailserver.domaine = domaine;

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
  services.jackett.enable = true;

  services.murmur.enable = true;
  services.murmur.bandwidth = 128000;
  services.murmur.imgMsgLength = 0;
  services.murmur.textMsgLength = 0;

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
