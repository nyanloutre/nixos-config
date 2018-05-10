{ lib, stdenv, fetchFromGitHub, sassc }:

stdenv.mkDerivation rec {
  name= "site-max-${version}";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "nyanloutre";
    repo = "site-max";
    rev = "85e30457291e6a1dfe85a5d7a78f226657bad279";
    sha256 = "0fj5w43gcvp0gq0xlknrf6yp0b48wg01686wp02fjc9npm424g0v";
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
