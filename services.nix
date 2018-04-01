{ config, pkgs, ... }:

{
  services.influxdb.enable = true;
  services.influxdb.dataDir = "/mnt/influxdb";

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

  services.emby.enable = true;

  networking.firewall.allowedTCPPorts = [
    3000 # Grafana
    8096 # Emby
  ];
}
