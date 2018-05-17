{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.site-musique;
in
{
  options.services.site-musique = {
    enable = mkEnableOption "Site musique";

    port = mkOption {
      type = types.int;
      example = 54321;
      description = "Local listening port";
    };

    domaine = mkOption {
      type = types.str;
      example = "example.com";
      description = "Domaine à utiliser";
    };
  };

  config = mkIf cfg.enable {

    services.haproxy-acme.services = {
      ${cfg.domaine} = { ip = "127.0.0.1"; port = cfg.port; auth = false; };
    };

    services.nginx.virtualHosts = {
      "musique" = {
        listen = [ { addr = "127.0.0.1"; port = cfg.port; } ];
        locations."/" = {
          root = pkgs.site-musique;
          index = "index.php";
          extraConfig = ''
            location ~* \.php$ {
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:/run/phpfpm/musique;
              include ${pkgs.nginx}/conf/fastcgi_params;
              include ${pkgs.nginx}/conf/fastcgi.conf;
            }
          '';
        };
      };
    };

    services.phpfpm.poolConfigs.musique = ''
      listen = /run/phpfpm/musique
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

  };
}
