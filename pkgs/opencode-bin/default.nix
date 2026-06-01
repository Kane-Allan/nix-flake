{
  lib,
  fetchurl,
  glibc,
  installShellFiles,
  makeWrapper,
  patchelf,
  ripgrep,
  stdenv,
  stdenvNoCC,
  zsh,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "1.15.10";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-linux-x64.tar.gz";
    hash = "sha256-pMDJSn/b9jfjrkecBGyknpJTcLTO5QPfunq2d6E80MU=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    patchelf
  ];

  buildInputs = [ glibc ];

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 opencode $out/bin/opencode
    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath ${lib.makeLibraryPath [ glibc ]} \
      $out/bin/opencode

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}

    completion() {
      local dir="$TMPDIR/opencode-completion-$1"
      mkdir -p "$dir/home" "$dir/cache" "$dir/config" "$dir/data" "$dir/tmp"
      HOME="$dir/home" \
        TMPDIR="$dir/tmp" \
        XDG_CACHE_HOME="$dir/cache" \
        XDG_CONFIG_HOME="$dir/config" \
        XDG_DATA_HOME="$dir/data" \
        "$out/bin/opencode" completion
    }

    mkdir -p "$TMPDIR/completions"
    completion bash > "$TMPDIR/completions/opencode.bash"
    SHELL=${zsh}/bin/zsh completion zsh > "$TMPDIR/completions/_opencode"

    installShellCompletion --cmd opencode \
      --bash "$TMPDIR/completions/opencode.bash" \
      --zsh "$TMPDIR/completions/_opencode"
  '';

  meta = {
    description = "AI coding agent, built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
})
