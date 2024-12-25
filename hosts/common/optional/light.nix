{
    programs.light.enable = true;
    services.actkbd.bindings = [
        { keys = [ 121 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -A 10"; }
        { keys = [ 122 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -U 10"; }
        { keys = [ 123 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -U 10"; }
    };
}
