{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name= "site-musique-${version}";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "nyanloutre";
    repo = "site-musique";
    rev = "42ffbfa85422f0d3e98e842ca702e07cb20be0c0";
    sha256 = "1ndfwg6rpkm2hn5naw0c91l6zbpcd011irs8imchqzbj4m2i7wgm";
  };

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
  '';

  meta = {
    description = "Site internet de l'association Musique Fraternité de Meyenheim";
    homepage = https://musique-meyenheim.fr/;
    maintainers = with stdenv.lib.maintainers; [ nyanloutre ];
    license = stdenv.lib.licenses.cc-by-nc-sa-40;
    platforms = stdenv.lib.platforms.all;
  };
}
