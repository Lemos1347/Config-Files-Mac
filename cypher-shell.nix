{ lib, stdenv, fetchzip, makeWrapper, jre, coreutils }:

stdenv.mkDerivation rec {
  pname = "cypher-shell";
  version = "5.26.0";

  src = fetchzip {
    url = "https://dist.neo4j.org/cypher-shell/cypher-shell-${version}.zip";
    hash = "sha256-pKQUantMTTUMLu+xw6oPxJ/OpL7pdVu0C5af86KdV54=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    cp -r . $out/libexec/cypher-shell

    chmod +x $out/libexec/cypher-shell/bin/cypher-shell
    patchShebangs $out/libexec/cypher-shell/bin/cypher-shell

    mkdir -p $out/bin
    makeWrapper $out/libexec/cypher-shell/bin/cypher-shell $out/bin/cypher-shell \
      --set JAVA_HOME "${jre}" \
      --prefix PATH : "${lib.makeBinPath [ jre coreutils ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line shell for executing Cypher queries against Neo4j";
    homepage = "https://neo4j.com";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "cypher-shell";
  };
}
