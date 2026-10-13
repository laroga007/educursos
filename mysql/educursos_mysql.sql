-- =====================================================
-- EduCursos - MySQL
-- Rol: opción de integración (muy usado en aplicaciones web)
-- Ejecutar conectada al servidor MySQL (crea la base sola)
-- =====================================================

-- 0) Crear la base y entrar en ella
--    Diferencia: utf8mb4 asegura acentos y caracteres especiales
CREATE DATABASE IF NOT EXISTS educursos CHARACTER SET utf8mb4;
USE educursos;

-- 1) Borrar las tablas si existen (primero las "hijas")
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS users;

-- 2) Crear tablas
--    Diferencia: las claves foráneas van al final de la tabla.
--    MySQL ignora "REFERENCES" si se escribe pegado a la columna.
CREATE TABLE users (
    user_id            INT           NOT NULL PRIMARY KEY,
    name               VARCHAR(100)  NOT NULL,
    email              VARCHAR(150)  NOT NULL UNIQUE,
    registration_date  DATE          NOT NULL
);

CREATE TABLE instructors (
    instructor_id  INT           NOT NULL PRIMARY KEY,
    name           VARCHAR(100)  NOT NULL,
    expertise      VARCHAR(100)
);

CREATE TABLE courses (
    course_id       INT           NOT NULL PRIMARY KEY,
    title           VARCHAR(150)  NOT NULL,
    category        VARCHAR(50)   NOT NULL,
    published_date  DATE
);

CREATE TABLE subscriptions (
    subscription_id    INT   NOT NULL PRIMARY KEY,
    user_id            INT   NOT NULL,
    course_id          INT   NOT NULL,
    subscription_date  DATE  NOT NULL,
    FOREIGN KEY (user_id)   REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (user_id, course_id)
);

-- 3) Cargar datos
INSERT INTO users (user_id, name, email, registration_date) VALUES
(1, 'Ana Martínez', 'ana@example.com',   '2023-06-15'),
(2, 'Juan Pérez',   'juan@example.com',  '2023-07-01'),
(3, 'Lucía Gómez',  'lucia@example.com', '2023-08-20');

INSERT INTO instructors (instructor_id, name, expertise) VALUES
(201, 'Carlos Díaz',  'SQL y Bases de Datos'),
(202, 'María Torres', 'Machine Learning');

INSERT INTO courses (course_id, title, category, published_date) VALUES
(101, 'Introducción a SQL',          'Data Science', '2023-01-10'),
(102, 'Machine Learning con Python', 'AI',           '2023-04-22'),
(103, 'Visualización de Datos',      'Data Viz',     '2023-06-30');

INSERT INTO subscriptions (subscription_id, user_id, course_id, subscription_date) VALUES
(1001, 1, 101, '2023-07-01'),
(1002, 2, 101, '2023-07-03'),
(1003, 1, 102, '2023-07-20'),
(1004, 3, 103, '2023-08-21');

-- 4) Validación (misma consulta en los 4 motores)
SELECT 'users' AS tabla, COUNT(*) AS filas FROM users
UNION ALL SELECT 'instructors',   COUNT(*) FROM instructors
UNION ALL SELECT 'courses',       COUNT(*) FROM courses
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions;
-- Esperado: users 3, instructors 2, courses 3, subscriptions 4

SELECT u.name AS alumno, c.title AS curso, s.subscription_date
FROM subscriptions s
JOIN users   u ON u.user_id   = s.user_id
JOIN courses c ON c.course_id = s.course_id
ORDER BY s.subscription_date;
