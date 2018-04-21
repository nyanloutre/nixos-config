{ config, lib, pkgs, ... }:

with lib;

let
  domaine = "nyanlout.re";
  riot_port = 52345;
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
    searx = { ip = "127.0.0.1"; port = 8888; auth = false; };
    riot = { ip = "127.0.0.1"; port = riot_port; auth = false; };
    matrix = { ip = "127.0.0.1"; port = 8008; auth = false; };
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
  
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/medias  192.168.0.0/24(ro,no_root_squash)
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
  services.sonarr.enable = true;
  services.jackett.enable = true;

  services.searx.enable = true;

  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "riot" = {
      listen = [ { addr = "127.0.0.1"; port = riot_port; } ];
      locations = { "/" = { root = pkgs.riot-web; }; };
    };
  };

  services.postgresql.enable = true;
  services.matrix-synapse = {
    enable = true;
    enable_registration = true;
    server_name = "nyanlout.re";
    listeners = [
      { # federation
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
          { compress = false; names = [ "federation" ]; }
        ];
        tls = true;
        type = "http";
        x_forwarded = false;
      }
      { # client
        bind_address = "127.0.0.1";
        port = 8008;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];
    database_type = "psycopg2";
    database_args = {
      database = "matrix-synapse";
    };
    extraConfig = ''
      max_upload_size: "100M"
    '';
  };

  networking.firewall.allowedTCPPorts = [
    111 2049 4000 4001 4002 # NFS
    3483 9000 9090 # Slimserver
    51413 # Transmission
    8448 # Matrix federation
  ];
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 # NFS
    3483 # Slimserver
    51413 # Transmission
  ];
}
