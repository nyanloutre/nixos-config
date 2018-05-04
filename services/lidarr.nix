{ config, pkgs, lib, ... }:

{
  systemd.services.lidarr = {
    description = "Lidarr";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "lidarr";
      Group = "lidarr";
      ExecStart = "${pkgs.lidarr}/bin/lidarr";
      Restart = "on-failure";
    };
  };

  users.extraUsers.lidarr = {
    home = "/var/lib/lidarr";
    createHome = true;
    group = "lidarr";
    isSystemUser = true;
  };

  users.extraGroups.lidarr = {};
}
