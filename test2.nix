{
webserver =
{ modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  services.httpd.enable = true;
  services.httpd.adminAddr = "hswongac@gmail.com";
  networking.firewall.allowedTCPPorts = [ 80 ];
};
}
