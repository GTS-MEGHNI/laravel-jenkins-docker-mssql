#!/bin/bash

# Start the cron service in the foreground
echo "Starting cron service..."
crond -f
