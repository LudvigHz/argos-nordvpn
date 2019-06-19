#!/bin/bash

# TODO get a better icon, waiting for nord to send
ICON_DISCONNECTED=$(curl -s 'https://www.vpncrew.com/wp-content/uploads/2018/01/nordvpn.png' | convert png:- -fuzz 40% -fill gray60 -opaque blue png:- | base64 -w 0)

ICON_CONNECTED="$(curl -s 'https://www.vpncrew.com/wp-content/uploads/2018/01/nordvpn.png' | convert png:- -fuzz 40% -fill green4 -opaque blue png:- | base64 -w 0)"

STATUS="$(nordvpn status)"

STATUS_CONNECTED=$(echo $STATUS | awk '{print $3}') # Lazy and quick way
STATUS_COUNTRY=$(echo $STATUS | awk '{for(i=1;i<=NF;i++) if ($i=="Country:") print $(i+1)}')
STATUS_CITY=$(echo $STATUS | awk '{for(i=1;i<=NF;i++) if ($i=="City:") print $(i+1)}')
STATUS_IP=$(echo $STATUS | awk '{for(i=1;i<=NF;i++) if ($i=="IP:") print $(i+1)}')
STATUS_PROTOCOL=$(echo $STATUS | awk '{for(i=1;i<=NF;i++) if ($i=="protocol:") print $(i+1)}')
STATUS_SERVER_NAME=$(echo $STATUS | awk '{for(i=1;i<=NF;i++) if ($i=="server:") print $(i+1)}')


# icon

if [[ $STATUS_CONNECTED == "Connected" ]]; then
  ICON=$ICON_CONNECTED
  COUNTRY_FLAG=$(curl -s \
    "https://public-us.opendatasoft.com/explore/dataset/country-flags/files/$(curl -s \
    "https://public-us.opendatasoft.com/api/records/1.0/search/?dataset=country-flags&q=$STATUS_COUNTRY&facet=country" \
    | jq -r '.records[0].fields.flag.id')/300/" | base64 -w 0)
else
  ICON=$ICON_DISCONNECTED
fi

echo " | image='$ICON' imageWidth=20"


# menu

echo "---"

if [[ $STATUS_CONNECTED == "Connected" ]]; then
  echo "<span color='#54a546'>Connected to:</span> <b>$STATUS_COUNTRY</b> | image='$COUNTRY_FLAG' imageWidth=20"
  echo "IP: <span color='#54a546'>$STATUS_IP</span>"
else
  echo -e "<span color='red'>Disconnected</span>"
  echo "IP: <span color='red'>$(curl -s ident.me)</span>"
fi

echo "---"

if [[ $STATUS_CONNECTED == "Disconnected" ]]; then
  echo "Quick connect | bash='nordvpn c' terminal=false refresh=true"
else
  echo "Disconnect | bash='nordvpn d' terminal=false refresh=true"
fi


# Start country list submenu
echo "Connect to"

for country in $(nordvpn countries); do
  echo "--$(echo $country | awk '{gsub(/,/,""); gsub(/_/," "); print;}')\
    | bash='nordvpn d && nordvpn c $(echo $country | awk '{gsub(/,/,""); print}')' terminal=false\
      trim=true refresh=true"
done
# End of country list


echo "---"
