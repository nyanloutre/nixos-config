{ config, pkgs, ... }:

{
  users.extraUsers.paul =
  { uid = 1000;
    isNormalUser = true;
    description = "Paul TREHIOU";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAF7VlzHzgg70uFbRFtVTS34qNBke/RD36mRENAsa33RxztxrqMsIDscAD/d6CTe6HDy7MCGzJnWCJSXj5iOQFM4RRMvKNEgCKPHqfhmfVvO4YZuMjNB0ufVf6zhJL4Hy43STf7NIWrenGemUP+OvVSwN/ujgl2KKw4KJZt25/h/7JjlCgsZm4lWg4xcjoiKL701W2fbEoU73XKdbRTgTvKoeK1CGxdAPFefFDFcv/mtJ7d+wIxw9xODcLcA66Bu94WGMdpyEAJc4nF8IOy4pW8AzllDi0qNEZGCQ5+94upnLz0knG1ue9qU2ScAkW1/5rIJTHCVtBnmbLNSAOBAstaGQJuSL40TWZ1oPA5i1qUEhunNcJ+Sgtp6XP69qY34T/AeJvHRyw5M5LfN0g+4ka9k06NPBhbpHFASz4M8nabQ0iM63++xcapnw/8gk+EPhYVKW86SsyTa9ur+tt6oDWEKNaOhgscX44LexY7jKdeBRt3GaObtBJtVLBRx3Z2aRXgjgnKGqS40mGRiSkqb2DShspI1l8DV2RrPiuwdBzXVQjWRc0KXmJrcgXX9uoPSxihxwaUQyvmITOV1Y+NEuek4gRkVNOxjoG7RGnaYvYzxEQVoI5TwZC2/DCrAUgCv8DQawkcpEiWnBq7Q5VnpmFx5juVQ/I0G8byOkPXgRUOk9 openpgp:0xAB524BBC" ];
  };
}
