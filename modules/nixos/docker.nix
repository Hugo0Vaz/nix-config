{pkgs, ...}:
{

  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose  
  ];

}
