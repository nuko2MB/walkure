{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    lact
  ];

  systemd = {
    services.lactd = {
      enable = false;
      wantedBy = [ "multi-user.target" ];
    };
    packages = with pkgs; [ lact ];
  };

  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
}
