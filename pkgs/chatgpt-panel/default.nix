{
  lib,
  stdenvNoCC,
  cairo,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  graphene,
  harfbuzz,
  makeWrapper,
  wrapGAppsHook4,
  pango,
  python3,
  gtk4,
  gtk4-layer-shell,
  webkitgtk_6_0,
  libsoup_3,
  glib-networking,
  gsettings-desktop-schemas,
}:
let
  python = python3.withPackages (ps: [ ps.pygobject3 ]);
  girDeps = [
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    graphene
    gtk4
    gtk4-layer-shell
    harfbuzz
    libsoup_3
    pango.out
    webkitgtk_6_0
  ];
in
stdenvNoCC.mkDerivation {
  pname = "chatgpt-panel";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    graphene
    gtk4
    gtk4-layer-shell
    harfbuzz
    pango
    webkitgtk_6_0
    libsoup_3
    glib-networking
    gsettings-desktop-schemas
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 src/chatgpt_panel.py $out/share/chatgpt-panel/chatgpt_panel.py
    install -Dm755 src/chatgpt_panelctl.py $out/share/chatgpt-panel/chatgpt_panelctl.py

    makeWrapper ${python}/bin/python3 $out/bin/chatgpt-panel \
      --add-flags $out/share/chatgpt-panel/chatgpt_panel.py \
      --prefix GI_TYPELIB_PATH : ${lib.makeSearchPath "lib/girepository-1.0" girDeps} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath girDeps} \
      --prefix LD_PRELOAD : ${gtk4-layer-shell}/lib/libgtk4-layer-shell.so \
      ''${gappsWrapperArgs[@]}

    makeWrapper ${python}/bin/python3 $out/bin/chatgpt-panelctl \
      --add-flags $out/share/chatgpt-panel/chatgpt_panelctl.py

    runHook postInstall
  '';

  meta = {
    description = "Right-side ChatGPT layer-shell panel";
    platforms = lib.platforms.linux;
    mainProgram = "chatgpt-panel";
  };
}
