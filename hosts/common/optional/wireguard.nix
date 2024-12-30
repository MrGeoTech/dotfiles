{ip, publicKey, ...}: {
    networking.firewall = {
        allowedUDPPorts = [ 29566 ];
    };
    # Enable wireguard
    networking.wg-quick.interfaces = {
        wg0 = {
            # IP address of this machine in the *tunnel network*
            address = [
                "10.0.1.3/32"
            ];

            # To match firewall allowedUDPPorts (without this wg
            # uses random port numbers).
            listenPort = 29566;
            mtu = 1420;

            # Path to the private key file.
            privateKeyFile = "/home/mrgeotech/.secrets/private_key";

            peers = [{
                publicKey = publicKey;
                presharedKeyFile = "/home/mrgeotech/.secrets/preshared_key";
                allowedIPs = [ "10.0.0.0/16" ];
                endpoint = "vpn.mrgeotech.net:29566";
                persistentKeepalive = 25;
            }];
        };
    };
                      }
