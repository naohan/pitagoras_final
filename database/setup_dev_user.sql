-- Crear usuario y base para desarrollo local (ejecutar como root en MySQL existente).
-- Ejemplo: mysql -u root -p < database/setup_dev_user.sql

CREATE DATABASE IF NOT EXISTS pitagoras
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'pitagoras'@'localhost' IDENTIFIED BY 'pitagoras';
CREATE USER IF NOT EXISTS 'pitagoras'@'127.0.0.1' IDENTIFIED BY 'pitagoras';

GRANT ALL PRIVILEGES ON pitagoras.* TO 'pitagoras'@'localhost';
GRANT ALL PRIVILEGES ON pitagoras.* TO 'pitagoras'@'127.0.0.1';

FLUSH PRIVILEGES;

-- Después importar el esquema:
--   mysql -u pitagoras -ppitagoras pitagoras < database/schema.sql
