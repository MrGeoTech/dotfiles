{ip, ...}: {
    # ssh only over the tunnel: port 22 stays shut on every other
    # interface, wg0 being trusted lets it through there.
    services.openssh.openFirewall = false;

    networking.firewall = {
        allowedUDPPorts = [ 29566 ];
        # Everything on the tunnel is ours: let any service on this
        # machine be reached from the other wireguard machines.
        trustedInterfaces = [ "wg0" ];
        # ssh from the lan too, so a dead wireguard server doesn't lock
        # us out. Private ranges only: never the open internet.
        extraCommands = ''
            for net in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
                iptables -A nixos-fw -p tcp --dport 22 -s "$net" -j nixos-fw-accept
            done
            for net in fe80::/10 fc00::/7; do
                ip6tables -A nixos-fw -p tcp --dport 22 -s "$net" -j nixos-fw-accept
            done
        '';
    };
    # Enable wireguard
    networking.wg-quick.interfaces = {
        wg0 = {
            # IP address of this machine in the *tunnel network*
            address = [
                "10.0.1.${ip}/32"
            ];

            # To match firewall allowedUDPPorts (without this wg
            # uses random port numbers).
            listenPort = 29566;
            mtu = 1420;

            # Path to the private key file.
            privateKeyFile = "/home/mrgeotech/.secrets/private_key";

            peers = [{
                publicKey = "tpMbShmlXi3jr+W8BUHfek5EdzuOjXolmaHRXLSlvCA=";
                presharedKeyFile = "/home/mrgeotech/.secrets/preshared_key";
                allowedIPs = [ "10.0.0.0/16" ];
                endpoint = "vpn.mrgeotech.net:29566";
                persistentKeepalive = 25;
            }];
        };
    };
                      }
