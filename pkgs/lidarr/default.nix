{ stdenv, fetchurl, mono58, sqlite, curl, libmediainfo, makeWrapper }:

stdenv.mkDerivation rec {
  name = "lidarr-${version}";
  version = "0.2.0.371";

  src = fetchurl {
    url = "https://github.com/lidarr/Lidarr/releases/download/v${version}/Lidarr.develop.${version}.linux.tar.gz";
    sha256 = "0lpyp9pj1cwlls4qkr5933k4ymhigp1f621clwrnxrr6hc2yhg90";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,share/${name}}
    cp -r * $out/share/${name}/.
    makeWrapper "${mono58}/bin/mono" $out/bin/lidarr \
      --add-flags "$out/share/${name}/Lidarr.exe" \
      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath [
          curl sqlite libmediainfo ]}
  '';

  meta = with stdenv.lib; {
    description = "A Usenet/BitTorrent music downloader.";
    homepage = http://lidarr.audio/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ nyanloutre ];
    platforms = platforms.all;
  };
}
