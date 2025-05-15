{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_large";
        padding = {
          right = 1;
        };
      };
      display = {
        size = {
          binaryPrefix = "si";
        };
        key = {
          width = 32;
        };
        color = "blue";
        separator = "   ";
      };
      modules = [
        "title"
        {
          type = "datetime";
          key = "Date & Time";
          format = "{1}-{3}-{11} {14}:{17}:{20}";
        }
        "separator"
        "host"
        "os"
        "kernel"
        "bios"
        {
          type = "bootmgr";
          key = "Boot Manager";
        }
        "break"
        "cpu"
        "gpu"
        "disk"
        {
          type = "physicaldisk";
          key = "Physical Disk";
          format = "{1} {2} ({5}) [{3}, {4}, {7}, {8}]";
        }
        "memory"
        "battery"
        "uptime"
        "break"
        "wifi"
        "bluetooth"
        "gamepad"
        "camera"
      ];
    };
  };
}
