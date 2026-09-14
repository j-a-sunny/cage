{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libxkbcommon,
  libglvnd,
  mesa,
  vulkan-loader,
  udev,
  seatd,
  libinput,
  wayland,
  xwayland,
}:

let
  version = "202511191018";

  sources = {
    x86_64-linux = {
      url = "https://github.com/waydroid-helper/cage/releases/download/release-${version}/cage-waydroid-helper_${version}_amd64";
      hash = "sha256-1Vky6JmgeMpz8FTYARiorQR+jzKWC9tD9K+39TmxqDE=";
    };
    aarch64-linux = {
      url = "https://github.com/waydroid-helper/cage/releases/download/release-${version}/cage-waydroid-helper_${version}_arm64";
      hash = "sha256-ROk25LJfh8okFu6cigkqc3WUjWBx3j0Sa/E64t+CAzc=";
    };
  };

  srcInfo =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "cage-waydroid-helper";
  inherit version;

  src = fetchurl {
    inherit (srcInfo) url hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libxkbcommon
    libglvnd
    mesa
    vulkan-loader
    udev
    seatd
    libinput
    wayland
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/cage-waydroid-helper
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/cage-waydroid-helper \
      --prefix PATH : ${lib.makeBinPath [ xwayland ]}
  '';

  meta = with lib; {
    description = "A Wayland kiosk (waydroid-helper fork) binary release";
    homepage = "https://github.com/waydroid-helper/cage";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "cage-waydroid-helper";
  };
}
