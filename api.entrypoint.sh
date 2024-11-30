#!/bin/bash

# Start nginx
/usr/sbin/nginx -g "daemon off;" &

# Start php-fpm (replace 'php-fpm7.4' with your PHP version if needed)
php-fpm -F &

# Keep the container running
tail -f /dev/null
