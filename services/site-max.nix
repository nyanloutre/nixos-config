{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.site-max;
in
{
  options.services.site-max = {
    enable = mkEnableOption "Site Max Spiegel";

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
      "max" = {
        listen = [ { addr = "127.0.0.1"; port = cfg.port; } ];
        locations."/" = {
          root = pkgs.site-max;
        };
      };
    };

  };
}
