# deceitmac
A tool to change/forge/spoof a mac address.

## Install

    sudo make install

## Usage

    $ deceitmac --help

### Examples
Create a random MAC address on wlp2s0 and reload dhcpcd.

    $ deceitmac --interface wlp2s0 --random --dhcpcd

Create a random MAC address and reload dhcpcd and tor after.

    $ deceitmac --interface enp3s0 --random --dhcpcd --tor
