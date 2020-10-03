{stdenv, jre_headless, unzip, gnumake}:

stdenv.mkDerivation {
  pname = "hath";

  version = "1.6.1";

  src = builtins.fetchurl {
    url = "https://repo.e-hentai.org/hath/HentaiAtHome_1.6.1_src.zip";
    sha256 = "0nqfgkp2iwxaap2jm4mklvyd02x9wxr7svr0704la2f1z153p14x";
  };

  setSourceRoot = "sourceRoot=`pwd`";

  unpackPhase = ''
    unzip $src
  '';

  buildPhase = ''
    JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8 make all
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/hath
    cp -v build/HentaiAtHome.jar $out/lib/hath/hath.jar

    cat > $out/bin/hath << EOF 
    #!/bin/sh
    exec ${jre_headless}/bin/java -Xms16m -Xmx512m -jar $out/lib/hath/hath.jar \$@ 
    EOF

    chmod +x $out/bin/hath
  '';

  nativeBuildInputs = [
    unzip
    gnumake
    jre_headless
  ];

  meta = with stdenv.lib; {
    description = "Hentai@Home server";
    licenses = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [
    ];
  };
}
