-- Etapa 3: añadir rol admin al ENUM de users.role
-- Ejecutar en bases existentes creadas con 001_cu01_auth.sql

ALTER TABLE users
    MODIFY COLUMN role ENUM('student', 'parent', 'admin') NOT NULL DEFAULT 'student';
