#!/bin/bash

# Start supervisord with the provided config file
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
