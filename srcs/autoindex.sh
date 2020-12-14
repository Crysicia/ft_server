#!/bin/bash

if [ "$1" = "off" ]; then
  sed -ri 's/autoindex on/autoindex off/' /etc/nginx/sites-available/localhost
  service nginx restart
else
  if [ "$1" = "on" ]; then
    sed -ri 's/autoindex off/autoindex on/' /etc/nginx/sites-available/localhost
	service nginx restart
  else
    echo "Unknown option, not modifing autoindex state"
  fi
fi
