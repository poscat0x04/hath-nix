{ config, lib, pkgs, options, ... }:

with lib;

let
  cfg = config.services.hath;
  homeDir = "/var/lib/hath";
  credential = pkgs.writeText "client_login" "${builtins.toString cfg.id}-${cfg.key}";
in
{
  options = {
    services.hath = {
      enable = mkEnableOption ''
        Hentai@Home daemon which will be run as the user "hath".
      '';

      id = mkOption {
        type = types.int;
        description = ''
          Client ID.
        '';
      };

      key = mkOption {
        type = types.str;
        description = ''
          Client Key.
        '';
      };

      disableBWM = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to disable the bandwidth monitor;
        '';
      };

      port = mkOption {
        type = types.port;
        default = 26653;
        description = ''
          TCP port number.
        '';
      };

      home = mkOption {
        type = types.path;
        default = homeDir;
        description = ''
          The directory which Hentai@Home service will run at.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = {
      hath = {
        isSystemUser = true;
        group = "hath";
        description = "Hentai@Home user";
        home = cfg.home;
        createHome = true;
      };
    };

    users.groups = {
      hath = {
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        cfg.port
      ];
    };

    systemd.services.hath = {
      description = "Hentai@Home service";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "hath";
        WorkingDirectory = cfg.home;
        ExecStart = ''
          ${pkgs.hath}/bin/hath ${if cfg.disableBWM then "--disable_bwm" else ""} --port ${builtins.toString cfg.port}
        '';

        SuccessExitStatus = 143;
        TimeoutStopSec = 10;
        Restart = "always";
        RestartSec = 5;
      };

      preStart = ''
        mkdir -p ${cfg.home}/data
        ln -sf ${credential} ${cfg.home}/data/client_login
      '';
    };
  };
}
