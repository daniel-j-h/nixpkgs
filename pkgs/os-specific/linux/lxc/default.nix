{ stdenv, fetchurl, fetchpatch, autoreconfHook, pkgconfig, perl, docbook2x
, docbook_xml_dtd_45, python3Packages

# Optional Dependencies
, libapparmor ? null, gnutls ? null, libselinux ? null, libseccomp ? null
, cgmanager ? null, libnih ? null, dbus ? null, libcap ? null, systemd ? null
}:

let
  enableCgmanager = cgmanager != null && libnih != null && dbus != null;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "lxc-${version}";
  version = "2.0.1";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    sha256 = "0l4fs6ckvip5akfa0vbjfk34ddvcv0c84mmpj9yrcfl67qwn31z9";
  };

  nativeBuildInputs = [
    autoreconfHook pkgconfig perl docbook2x python3Packages.wrapPython
  ];
  buildInputs = [
    libapparmor gnutls libselinux libseccomp cgmanager libnih dbus libcap
    python3Packages.python systemd
  ];

  patches = [
    ./support-db2x.patch
  ];

  XML_CATALOG_FILES = "${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-api-docs"
    "--with-init-script=none"
    "--with-distro=nixos" # just to be sure it is "unknown"
  ] ++ optional (libapparmor != null) "--enable-apparmor"
    ++ optional (libselinux != null) "--enable-selinux"
    ++ optional (libseccomp != null) "--enable-seccomp"
    ++ optional (libcap != null) "--enable-capabilities"
    ++ [
    "--disable-examples"
    "--enable-python"
    "--disable-lua"
    "--enable-bash"
    (if doCheck then "--enable-tests" else "--disable-tests")
    "--with-rootfs-path=/var/lib/lxc/rootfs"
  ];

  doCheck = false;

  installFlags = [
    "localstatedir=\${TMPDIR}"
    "sysconfdir=\${out}/etc"
    "sysconfigdir=\${out}/etc/default"
    "READMEdir=\${TMPDIR}/var/lib/lxc/rootfs"
    "LXCPATH=\${TMPDIR}/var/lib/lxc"
  ];

  postInstall = ''
    wrapPythonPrograms
  '';

  meta = {
    homepage = "http://lxc.sourceforge.net";
    description = "userspace tools for Linux Containers, a lightweight virtualization system";
    license = licenses.lgpl21Plus;

    longDescription = ''
      LXC is the userspace control package for Linux Containers, a
      lightweight virtual system mechanism sometimes described as
      "chroot on steroids". LXC builds up from chroot to implement
      complete virtual systems, adding resource management and isolation
      mechanisms to Linux’s existing process management infrastructure.
    '';

    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington globin fpletz ];
  };
}
