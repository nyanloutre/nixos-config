with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "organizr-${version}";
  version = "1.75";

  src = fetchFromGitHub {
    owner = "causefx";
    repo = "Organizr";
    rev = version;
    sha256 = "13h6cgqq3gyg5d3ikj7k85igpg6al7y9xdsxammkr8y5dzfbkm36";
  };

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
    ln -s /var/lib/organizr/config.php $out/config/config.php
  '';

  meta = {
    description = "Organizr dashboard";
    homepage = https://github.com/causefx/Organizr;
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.all;
  };
}
