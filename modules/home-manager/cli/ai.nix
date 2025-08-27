{pkgs, ...}: {
    home.packages = with pkgs; [
    crush
    opencode
  ];
}
