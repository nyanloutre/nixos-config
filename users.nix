{ config, pkgs, ... }:

{
  users.extraUsers.paul =
  { uid = 1000;
    isNormalUser = true;
    description = "Paul TREHIOU";
    extraGroups = [ "wheel" "networkmanager" "medias" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAF7VlzHzgg70uFbRFtVTS34qNBke/RD36mRENAsa33RxztxrqMsIDscAD/d6CTe6HDy7MCGzJnWCJSXj5iOQFM4RRMvKNEgCKPHqfhmfVvO4YZuMjNB0ufVf6zhJL4Hy43STf7NIWrenGemUP+OvVSwN/ujgl2KKw4KJZt25/h/7JjlCgsZm4lWg4xcjoiKL701W2fbEoU73XKdbRTgTvKoeK1CGxdAPFefFDFcv/mtJ7d+wIxw9xODcLcA66Bu94WGMdpyEAJc4nF8IOy4pW8AzllDi0qNEZGCQ5+94upnLz0knG1ue9qU2ScAkW1/5rIJTHCVtBnmbLNSAOBAstaGQJuSL40TWZ1oPA5i1qUEhunNcJ+Sgtp6XP69qY34T/AeJvHRyw5M5LfN0g+4ka9k06NPBhbpHFASz4M8nabQ0iM63++xcapnw/8gk+EPhYVKW86SsyTa9ur+tt6oDWEKNaOhgscX44LexY7jKdeBRt3GaObtBJtVLBRx3Z2aRXgjgnKGqS40mGRiSkqb2DShspI1l8DV2RrPiuwdBzXVQjWRc0KXmJrcgXX9uoPSxihxwaUQyvmITOV1Y+NEuek4gRkVNOxjoG7RGnaYvYzxEQVoI5TwZC2/DCrAUgCv8DQawkcpEiWnBq7Q5VnpmFx5juVQ/I0G8byOkPXgRUOk9 openpgp:0xAB524BBC" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCACVI2dL4AmOdcb7RSl3JZpfK33NhqrYFfWfXMYow5SPJ9VPteOp5kVvKUuSbGH3chjpttYC/ueQJJhFagiKmkeftQTslIw6C009wUExGpJwRotHqISXv2ctURGURKy2FF848whd7xZJzdj49ZJ6S+SCbRFZvVWfT2dP/JwTiWW1mbEaWKyOgrixH6wSKt9ECumjX9KjqSWGw+k3yLJxIhdqiZAjNv4soJs1mQYdIlFCXCuznzoZIQBexZPQCx0j9HjczPz1feMLWkrHzEMexNjsBE2uA6yXLbH1wa8xCJ4VOeD7u9JqVY579AsicD62G+qIgw0B2zmyz7xTrdPv+061zmYn6qYr8EXGTk4dVgedZp8M1XzZ1PVoeeftPFcClXC7zCGyCR2uzJbQLzlaTwZrdghAiS9UhMRuKpNgZy2zDWw4MqdojrF5bndPkoijlXWYrPYBFED5OU1mpwzpanYgldowJC/Ixjwi+Hmse2q4XgZ+egfuotBqPfqB+bWsCa5GNiJWGdLP69uBSsXubGnqLwvE0FAQ2GHb+SEoZKFy/QV9GzOLlVrGlgK5YFgKJD+Q1nn1QRycXt1oMVC/AtR/NshOGanhdvIRpPATGmaxLVXSY093vyAOW4MPrS00fPAXzAfJUwIuWcloFfLMo5Jitj5rpE1s6FX8xrl4upQ== paul@nyanlout.re" ];
  };
  
  users.extraUsers.victor =
  { uid = 1111;
    isNormalUser = true;
    description = "Victor SENE";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCaCc2qcQsd/VPDX1K97zJ/MjObWnTfRkA98xeNnVTeGoMmbf/fW1KszB+3IYCngCKLhliotHEXkqOK24vMLZ9ylVPTIPLNY5OWLFRQSOU/OykP8r4ikDWmMOwI+tqkoBknTUZdA1MN1JmkpE1cWL8vRJ7mnwl/p7xCMHV19N5+UdoIx3bFsm0CCUMIYSaIefoD3tpIzmgVqBkIH4FSmNwvXHwcXhhOTGqXbTJYC/GY2mI0AFvZI3T61ReV325ms7QRQlElXP8Rv8lpjr57VISNjKsPPNvifLjy10RjIS8iNioN6fJ0XBCfKOmm37VX86aFkAgWdpzxGojprOXnViwZEWSegnvKGx8FNx3gB54zF76e6koWS+qnYf9UTdogO6uXhXZb7AoMC9XD0/l6Egh8HzPWAUZtLx74zhB8ufoKmzqOp4YrCK8Cu4N/1UTFyPUoeSCZJdcE/9iqldym06mOi4rDV5cKCzs+Q0bVP8+x8SZ9ajYUH7l4sxjDHtHiyAYniWIxGPO5NazCfx7J+1GGzbtV0HuBwE/U20z+nBy+WZ4MowQTNb2E2uhq4OgQASx7uTKtyhnfT09A3toHZVerfH8ET8YEVnwdYMCA0GHYMOZ48h1ORdE+OLyqRlxjYTCB17Kc2icSL3iv8Yd66vQagy3A+C8OhZP1rdc15bEZnw== openpgp:0x28DF0235" ];
   };

  users.extraGroups.medias =
  { members = [ "slimserver" "radarr" "sonarr" "emby" "transmission" "lidarr" ];
  };
}
