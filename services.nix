{ config, pkgs, ... }:

{
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
        ExecStopPost = "/usr/bin/rkt gc --mark-only";
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
    3000 # Grafana
    8096 # Emby
    111 2049 4000 4001 4002 # NFS
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
  ];
}
