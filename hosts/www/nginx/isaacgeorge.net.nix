{ pkgs, lib, config, ... }:
let
    user = "webuser";
    appDomain = "isaacgeorge.net";
    dataDir = "/var/www/${appDomain}/";
in {
    services.phpfpm.pools.${appDomain} = {
        user = user;
        settings = {
            "listen.owner" = config.services.nginx.user;
            "listen.group" = config.services.nginx.group;
            "listen.mode" = "0660";
            "catch_workers_output" = 1;
        };
    };

    users.groups.${user}.members = [ "${user}" ];
    users.users.${user} = {
        isSystemUser = true;
        group = "${user}";
    };
    users.users.nginx.extraGroups = [ "${user}"];

    services.nginx = {
        enable = true;

        virtualHosts = {
            ${appDomain} = {
                root = "${dataDir}";

                extraConfig = ''
                    index index.php;
                '';

                locations = {
                    "~ ^(.+\\.php)(.*)$"  = {
                        extraConfig = ''
                            # Check that the PHP script exists before passing it
                            try_files $fastcgi_script_name =404;
                            include ${config.services.nginx.package}/conf/fastcgi_params;
                            fastcgi_split_path_info  ^(.+\.php)(.*)$;
                            fastcgi_pass unix:${config.services.phpfpm.pools.${user}.socket};
                            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
                            fastcgi_param  PATH_INFO        $fastcgi_path_info;

                            include ${pkgs.nginx}/conf/fastcgi.conf;            
                        '';
                    };
                    # Allow robots (what do I have to loose?)
                    "/robots.txt" = {
                        extraConfig = ''
                            rewrite ^/(.*)  $1;
                            return 200 "User-agent: *\nAllow: /";
                        '';
                    };
                };
            };
        };
    };
}
