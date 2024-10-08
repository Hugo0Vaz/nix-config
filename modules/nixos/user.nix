{ pkgs, ... }: {
  users.users.hugomvs = {
    isNormalUser = true;
    description = "Hugo Martins Vaz Silva";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kdePackages.kate ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

}
