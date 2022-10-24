
{
webserver =
{ modulesPath, config, lib, pkgs, ... }: let
  test = pkgs.writeTextDir "index.php" ''
    <?php
    phpinfo();
  '';
in {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.phpfpm.pools.test = {
    user = "test";
    settings = {
      "listen.owner" = config.services.httpd.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };
  services.httpd = {
    enable = true;
    adminAddr = "hswongac@gmail.com";
    extraModules = [ "proxy_fcgi" ];
    virtualHosts.test = {
      documentRoot = test;
      extraConfig = ''
        <Directory "${test}>
          <FilesMatch "\.php$">
            <If "-f %{REQUEST_FILENAME}">
              SetHandler "proxy:unix:${config.services.phpfpm.pools.test.socket}|fcgi://localhost/"
            </If>
          </FilesMatch>
          Require all granted
          DirectoryIndex index.php
          AllowOverride All
        </Directory>
      '';
    };
  };
  users.users.test = {
    isSystemUser = true;
    createHome = true;
    home = test;
    group  = "test";
  };
  users.groups.test = {};
};
}
