{ config, lib, pkgs, ... }:

with lib;

let
  domaine = "nyanlout.re";

  riot_port = 52345;
  organizr_port = 52346;
  pgmanage_port = 52347;
  max_port = 52348;
  musique_port = 52349;
in

{
  imports = [
    ./services/haproxy-acme.nix
    ./services/mail-server.nix
    ./services/lidarr.nix
  ];

  services.haproxy-acme.enable = true;
  services.haproxy-acme.domaine = domaine;
  services.haproxy-acme.services = {
    grafana = { ip = "127.0.0.1"; port = 3000; auth = false; };
    emby = { ip = "127.0.0.1"; port = 8096; auth = false; };
    radarr = { ip = "127.0.0.1"; port = 7878; auth = false; };
    sonarr = { ip = "127.0.0.1"; port = 8989; auth = false; };
    lidarr = { ip = "127.0.0.1"; port = 8686; auth = false; };
    transmission = { ip = "127.0.0.1"; port = 9091; auth = true; };
    syncthing = { ip = "127.0.0.1"; port = 8384; auth = true; };
    jackett = { ip = "127.0.0.1"; port = 9117; auth = true; };
    searx = { ip = "127.0.0.1"; port = 8888; auth = false; };
    riot = { ip = "127.0.0.1"; port = riot_port; auth = false; };
    matrix = { ip = "127.0.0.1"; port = 8008; auth = false; };
    organizr = { ip = "127.0.0.1"; port = organizr_port; auth = true; };
    calibre = { ip = "127.0.0.1"; port = 8080; auth = false; };
    pgmanage = { ip = "127.0.0.1"; port = pgmanage_port; auth = true; };
    max = { ip = "127.0.0.1"; port = max_port; auth = false; };
    musique = { ip = "127.0.0.1"; port = musique_port; auth = false; };
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
  services.grafana.extraOptions = {
    SERVER_ROOT_URL = "https://grafana.${domaine}";
    SMTP_ENABLED = "true";
    SMTP_FROM_ADDRESS = "grafana@${domaine}";
    SMTP_SKIP_VERIFY = "true";
  };

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
      /exports/steam  192.168.0.0/24(rw,no_root_squash)
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
    "organizr" = {
      listen = [ { addr = "127.0.0.1"; port = organizr_port; } ];
      locations."/" = {
        root = pkgs.organizr;
        index = "index.php";
        extraConfig = ''
          location ~* \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/run/phpfpm/nginx;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          }
        '';
      };
    };
    "max" = {
      listen = [ { addr = "127.0.0.1"; port = max_port; } ];
      locations = { "/" = { root = pkgs.site-max; }; };
    };
    "musique" = {
      listen = [ { addr = "127.0.0.1"; port = musique_port; } ];
      locations."/" = {
        root = pkgs.site-musique;
        index = "index.php";
        extraConfig = ''
          location ~* \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/run/phpfpm/nginx;
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          }
        '';
      };
    };
  };

  services.phpfpm.poolConfigs.mypool = ''
    listen = /run/phpfpm/nginx
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    user = nginx
    pm = dynamic
    pm.max_children = 75
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 20
    pm.max_requests = 500
    php_admin_value[error_log] = 'stderr'
    php_admin_flag[log_errors] = on
    catch_workers_output = yes
  '';

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

  services.calibre-server.enable = true;
  services.calibre-server.libraryDir = "/var/lib/calibre";
  users.extraUsers.calibre-server = {
    home = "/var/lib/calibre";
  };

  services.pgmanage.enable = true;
  services.pgmanage.port = pgmanage_port;
  services.pgmanage.connections = {
    localhost = "hostaddr=127.0.0.1 port=5432 dbname=postgres";
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
