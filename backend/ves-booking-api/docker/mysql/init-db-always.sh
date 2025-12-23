#!/bin/bash
# This script ensures the database exists on every container start
# It's called from the entrypoint

set -e

echo "Ensuring database 'ves_booking_api' exists..."

mysql -uroot -proot <<EOF
CREATE DATABASE IF NOT EXISTS ves_booking_api CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'vesbooking'@'%';
GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'root'@'%';
FLUSH PRIVILEGES;
EOF

echo "Database check complete."

