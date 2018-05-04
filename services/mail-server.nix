{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.mailserver;
in
{
  options.services.mailserver = {
    enable = mkEnableOption "Mail Server";
    domaine = mkOption {
      type = types.string;
      example = "example.com";
      description = "Nom de domaine du serveur de mails";
    };
  };

  imports = [
    (builtins.fetchTarball {
      url = "https://github.com/r-raymond/nixos-mailserver/archive/v2.1.4.tar.gz";
      sha256 = "1n7k8vlsd1p0fa7s3kgd40bnykpk7pv579aqssx9wia3kl5s7c1b";
    })
  ];

  config = mkIf cfg.enable {

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.domaine}";
      domains = [ cfg.domaine ];

      # A list of all login accounts. To create the password hashes, use
      # mkpasswd -m sha-512 "super secret password"
      loginAccounts = {
        "paul@${cfg.domaine}" = {
          hashedPassword = "$6$8wWQbtqVqUoH8$pQKg0bZPcjCbuPvyhjJ1lQy949M/AgfmAye/hDEIVUnCfwtlUxC1yj8CBHpNKeiiXhd8IUqk9r0/IJNvB6okf0";
        };
      };

      # Certificate setup
      certificateScheme = 1;
      certificateFile = "/var/lib/acme/${cfg.domaine}/fullchain.pem";
      keyFile = "/var/lib/acme/${cfg.domaine}/key.pem";

      # Length of the Diffie Hillman prime used
      dhParamBitLength = 4096;

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = true;
      enableImapSsl = true;
      enablePop3Ssl = true;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };

    security.acme.certs = {
      "${cfg.domaine}" = {
        extraDomains = {
          "mail.${cfg.domaine}" = null;
        };
        postRun = ''
          systemctl reload dovecot2.service
        '';
      };
    };

  };
}
