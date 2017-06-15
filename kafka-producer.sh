while true; do
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1
  sleep 2
done
