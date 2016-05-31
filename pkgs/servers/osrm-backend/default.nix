{stdenv, fetchFromGitHub, cmake, luabind, stxxl, tbb, boost, expat, bzip2, zlib, substituteAll}:

stdenv.mkDerivation rec {
  name = "osrm-backend-${version}";
  version = "5.2.0-rc.1";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner  = "Project-OSRM";
    repo   = "osrm-backend";
    sha256 = "1v4x146z1vw6ihsfvl1gicpi6ykdzgvdzhpy5iysjgz5dix92s7n";
  };

  patches = [
    ./5.2.0-gcc-binutils.patch
    (substituteAll {
      src = ./5.2.0-default-profile-path.template.patch;
    })
  ];

  buildInputs = [ cmake luabind stxxl tbb boost expat bzip2 zlib ];

  postInstall = "mkdir -p $out/share/osrm-backend && cp -r ../profiles $out/share/osrm-backend/profiles";

  meta = {
    homepage = https://github.com/Project-OSRM/osrm-backend/wiki;
    description = "The Open Source Routing Machine is a high performance routing engine written in C++11 designed to run on OpenStreetMap data";
    license = stdenv.lib.licenses.bsd2;
  };
}
