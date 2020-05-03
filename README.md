# deceitmac
A posix shell to change/forge/spoof a mac address anytimes.

## Install

    sudo make install

## Usage

    $ deceitmac --help

## Systemd
To use the systemd service, copy the .service in the right place `/lib/systemd/system` or `/usr/lib/systemd/system` and enable it:

    $ sudo systemctl enable deceitmac@wlp2s0
    $ sudo systemctl enable deceitmac@enp3s0
    
### Examples
Create a random MAC address on wlp2s0 and reload dhcpcd.

    $ deceitmac --interface wlp2s0 --random --dhcpcd

Create a random MAC address and reload dhcpcd and tor after.

    $ deceitmac --interface enp3s0 --random --dhcpcd --tor
