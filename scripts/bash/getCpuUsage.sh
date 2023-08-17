#not used
printf "%.0f" `mpstat | awk '/all/ { print $4 }'`
