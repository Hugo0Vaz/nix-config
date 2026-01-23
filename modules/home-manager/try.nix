{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    ruby
  ];

  # TODO: verificar quando o pacote try tiver corrigido https://github.com/tobi/try/pull/91
  programs.try = {
    enable = true;
    path = "~/Projetos/tryouts";
    package = inputs.try.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp try.rb $out/bin/try
        cp -r lib/* $out/lib/
        chmod +x $out/bin/try

        # Update the require_relative paths to use absolute paths
        substituteInPlace $out/bin/try \
          --replace "require_relative 'lib/" "require_relative '$out/lib/"

        wrapProgram $out/bin/try \
          --prefix PATH : ${pkgs.ruby}/bin
      '';
    });
  };
}
