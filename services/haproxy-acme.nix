{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.haproxy-acme;

  nginx_port = 54321;
in
{
  options.services.haproxy-acme = {
    enable = mkEnableOption "HAproxy + ACME";

    domaine = mkOption {
      type = types.string;
      example = "example.com";
      description = ''
        Sous domaine à utiliser

        Il est necessaire d'avoir un enregistrement pointant sur la wildcard de ce domaine vers le serveur
      '';
    };

    services = mkOption {
      type = with types; attrsOf (submodule { options = {
        ip = mkOption { type = str; description = "IP address"; };
        port = mkOption { type = int; description = "Port number"; };
        auth = mkOption { type = bool; description = "Enable authentification"; default = false; };
      }; });
      example = ''
        haproxy_backends = {
          example = { ip = "127.0.0.1"; port = 1234; auth = false; };
        };
      '';
      description = "Liste des noms de domaines associés à leur backend";
    };
  };

  config = mkIf cfg.enable {

    services.haproxy.enable = true;

    services.haproxy.config = ''
      global
        log /dev/log local0
        log /dev/log local1 notice
        user haproxy
        group haproxy
        ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
        ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
        ssl-default-server-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256
        ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
      defaults
        option forwardfor
        option http-server-close
        timeout client 10s
        timeout connect 4s
        timeout server 30s
      userlist LOUTRE
        user paul password $6$6rDdCtzSVsAwB6KP$V8bR7KP7FSL2BSEh6n3op6iYhAnsVSPI2Ar3H6MwKrJ/lZRzUI8a0TwVBD2JPnAntUhLpmRudrvdq2Ls2odAy.
      frontend public
        bind :::80 v4v6
        bind :::443 v4v6 ssl crt /var/lib/acme/${cfg.domaine}/full.pem alpn h2,http/1.1
        mode http
        acl letsencrypt-acl path_beg /.well-known/acme-challenge/
        acl haproxy-acl path_beg /haproxy
        redirect scheme https code 301 if !{ ssl_fc } !letsencrypt-acl
        http-response set-header Strict-Transport-Security max-age=15768000
        use_backend letsencrypt-backend if letsencrypt-acl
        use_backend haproxy_stats if haproxy-acl

      ${concatStrings (
        mapAttrsToList (name: value:
          "  acl ${name}-acl hdr(host) -i ${name}\n"
        + "  use_backend ${name}-backend if ${name}-acl\n"
        ) cfg.services)}

      backend letsencrypt-backend
        mode http
        server letsencrypt 127.0.0.1:${toString nginx_port}
      backend haproxy_stats
        mode http
        stats enable
        stats hide-version
        acl AuthOK_LOUTRE http_auth(LOUTRE)
        http-request auth realm LOUTRE if !AuthOK_LOUTRE

      ${concatStrings (
        mapAttrsToList (name: value:
          ''
          backend ${name}-backend
            mode http
            server ${name} ${value.ip}:${toString value.port}
            ${(if value.auth then (
              "\n  acl AuthOK_LOUTRE http_auth(LOUTRE)\n"
            + "  http-request auth realm LOUTRE if !AuthOK_LOUTRE\n"
            ) else "")}
          ''
        ) cfg.services)}

    '';

    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "acme" = {
        listen = [ { addr = "127.0.0.1"; port = nginx_port; } ];
        locations = { "/" = { root = "/var/www/challenges"; }; };
      };
    };

    security.acme.certs = {
      ${cfg.domaine} = {
        extraDomains = mapAttrs' (name: value:
          nameValuePair ("${name}") (null)
        ) cfg.services;
        webroot = "/var/www/challenges";
        email = "paul@nyanlout.re";
        user = "haproxy";
        group = "haproxy";
        postRun = ''
          systemctl reload haproxy.service
        '';
      };
    };
    security.acme.directory = "/var/lib/acme";

    networking.firewall.allowedTCPPorts = [
      80 443
    ];

  };
}
