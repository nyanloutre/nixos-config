{ lib, stdenv, fetchFromGitHub, sassc }:

stdenv.mkDerivation rec {
  name= "site-max-${version}";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "nyanloutre";
    repo = "site-max";
    rev = "d867dc88282802fda5616c0320456cab38e57d88";
    sha256 = "05q1jn0ak04kpcih51nxsy4phf15vg2xlsvp26lycncfygkq2vy0";
  };

  buildPhase = ''
    ${sassc}/bin/sassc -m auto -t compressed scss/creative.scss css/creative.css
  '';

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
  '';

  meta = {
    description = "Site de présentation de Max Spiegel";
    homepage = https://maxspiegel.fr/;
    maintainers = with stdenv.lib.maintainers; [ nyanloutre ];
    license = stdenv.lib.licenses.cc-by-nc-sa-40;
    platforms = stdenv.lib.platforms.all;
  };
}
