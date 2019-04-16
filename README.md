##MacSpoofer For Mass Deployments

This script permanently spoofs the MAC address of a linux machine and adds an entry to a remote file detailing the original MAC and the new one.
I made some changes to [dtsioumas' original script](https://github.com/dtsioumas/macspoofer/) just to make the whole process more clear and simpler as my modifications aim specifically for a mass deployment usecase for fresh installs.

In order to make the script work you must edit the file and change the user_with_cert and dhcp_server_ip fields with a remote user whose passless private key is located in root's .ssh/ and the (dhcp) server where this user is located.

The idea is to use this a first boot script so you can have a centralized list of all new linux hosts which you can use to configure your dhcp services accordingly.