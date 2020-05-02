#!/usr/bin/env sh

set -o errexit

CONF=/etc/deceitmac

cyan='\e[0;96m'
blue='\e[0;94m'
white='\e[0;97m'
endc='\e[0m'

die() { echo "[-] $1" ; exit 1; }

ctrl_net() {
  [ -z "$net" ] && die "Please, call $0 with -i <interface-name>"
  if ! cat < /proc/net/dev | tr -d ":" | awk '{print $1}' | grep -q "$net\$" ; then
    die "Your network interface is no found."
  fi
}

save_origin() {
  ctrl_net
  head
  origin=$(ip link show "$net" | grep -i ether | awk '{print $2}')
  [ -d $CONF ] || die "please, install the program with 'make install'"
  sudo sh -c "[ -f $CONF/origin_\"$net\" ] || {
    echo \"origin $origin saved for $net\"
    echo \"$origin\" > \"$CONF/origin_$net\"
  }"
}

# Solution to create a valid address
# https://unix.stackexchange.com/questions/279910/how-go-generate-a-valid-and-random-mac-address
random_mac() {
  mac=$(printf ""; dd bs=1 count=1 if=/dev/urandom 2>/dev/null | hexdump -v -e '/1 "%02X"')
  mac="${mac} $(printf ""; dd bs=1 count=5 if=/dev/urandom 2>/dev/null | hexdump -v -e '/1 ":%02X"')"
  lastfive=$( echo "$mac" | cut -d: -f 2-6 )
  firstbyte=$( echo "$mac" | cut -d: -f 1 )
  firstbyte=$( printf '%02X' $(( 0x$firstbyte & 254 | 2)) )
  mac="$firstbyte:$lastfive"
}

apply() {
  if [ -n "$mac" ] ; then
    sudo ip link set dev "$net" down
    sleep 1
    sudo ip link set dev "$net" address "$mac"
    sudo ip link set dev "$net" up
    sleep 1
    echo "Changed MAC $origin to $mac"
  fi
}

kill_dhcpcd() {
  pgrep -x dhcpcd | xargs sudo kill -9
}

reload_dhcpcd() {
  echo "Reload dhcpcd..."
  sudo systemctl restart dhcpcd
}

reload_tor() {
  echo "Reload tor..."
  sudo systemctl restart tor
}

banner() {
  cat << EOF
    ▗▖                 █
    ▐▌                 ▀   ▐▌
  ▟█▟▌ ▟█▙  ▟██▖ ▟█▙  ██  ▐███ ▐█▙█▖ ▟██▖ ▟██▖
 ▐▛ ▜▌▐▙▄▟▌▐▛  ▘▐▙▄▟▌  █   ▐▌  ▐▌█▐▌ ▘▄▟▌▐▛  ▘
 ▐▌ ▐▌▐▛▀▀▘▐▌   ▐▛▀▀▘  █   ▐▌  ▐▌█▐▌▗█▀▜▌▐▌
 ▝█▄█▌▝█▄▄▌▝█▄▄▌▝█▄▄▌▗▄█▄▖ ▐▙▄ ▐▌█▐▌▐▙▄█▌▝█▄▄▌
  ▝▀▝▘ ▝▀▀  ▝▀▀  ▝▀▀ ▝▀▀▀▘  ▀▀ ▝▘▀▝▘ ▀▀▝▘ ▝▀▀
EOF
  # generated with toilet -F cropt -f smmono12 deceitmac
}

head() { printf "$cyan--------------------------------------$endc\\n"; }
doption() { printf "  $blue%s   $white%s$endc\\n" "$1" "$2"; }

display_help() {
  printf "\\n"
  doption "-r, --random" "Generate a random MAC"
  doption "-i, --interface" "Name of the interface to change"
  doption "-d, --dhcpcd" "Reload dhcpcd after the change"
  doption "-t, --tor" "Reload tor after the change"
  doption "-h, --help" "Display this message"
  exit 0
}

no_args() {
  if [ "$#" -eq 0 ] ; then
    printf "\\n%s\\n" "$0: Argument required"
    printf "%s\\n" "Try '$0 --help' for more information."
    exit 1
  fi
}

options() {
  no_args "$@"
  while [ "$#" -gt 0 ] ; do
    case "$1" in
      -i | --interface) net="$2"; shift ; shift ;;
      -r | --random) random_mac ; shift ;;
      -d | --dhcpcd) DHCPCD=true ; shift ;;
      -t | --tor) TOR=true ; shift ;;
      -h | --help) display_help ; shift ;;
      *)
        printf "\\n%s\\n" "$0: Invalid argument"
        printf "%s\\n" "Try '$0 --help' for more information."
        exit 1
        ;;
    esac
  done
}

main() {
  options "$@"
  banner
  save_origin
  [ -n "$DHCPCD" ] && kill_dhcpcd
  apply
  [ -n "$DHCPCD" ] && reload_dhcpcd
  [ -n "$TOR" ] && reload_tor
}

main "$@"
