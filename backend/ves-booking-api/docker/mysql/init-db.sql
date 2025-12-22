-- Ensure database exists
CREATE DATABASE IF NOT EXISTS ves_booking_api CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to user (if it exists)
GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'vesbooking'@'%';
GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'root'@'%';

FLUSH PRIVILEGES;

