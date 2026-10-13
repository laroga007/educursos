-- =====================================================
-- EduCursos - SQL Server (dialecto T-SQL)
-- Rol: entorno de desarrollo y enseñanza inicial
-- Ejecutar conectada a la base educursos
-- =====================================================

-- 1) Borrar las tablas si existen (primero las "hijas")
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS users;

-- 2) Crear tablas
CREATE TABLE users (
    user_id            INT            NOT NULL PRIMARY KEY,
    name               NVARCHAR(100)  NOT NULL,
    email              NVARCHAR(150)  NOT NULL UNIQUE,
    registration_date  DATE           NOT NULL
);

CREATE TABLE instructors (
    instructor_id  INT            NOT NULL PRIMARY KEY,
    name           NVARCHAR(100)  NOT NULL,
    expertise      NVARCHAR(100)
);

CREATE TABLE courses (
    course_id       INT            NOT NULL PRIMARY KEY,
    title           NVARCHAR(150)  NOT NULL,
    category        NVARCHAR(50)   NOT NULL,
    published_date  DATE
);

CREATE TABLE subscriptions (
    subscription_id    INT   NOT NULL PRIMARY KEY,
    user_id            INT   NOT NULL,
    course_id          INT   NOT NULL,
    subscription_date  DATE  NOT NULL,
    FOREIGN KEY (user_id)   REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (user_id, course_id)  -- un alumno no se inscribe dos veces al mismo curso
);

-- 3) Cargar datos (N'...' = texto Unicode, para acentos)
INSERT INTO users (user_id, name, email, registration_date) VALUES
(1, N'Ana Martínez', N'ana@example.com',   '2023-06-15'),
(2, N'Juan Pérez',   N'juan@example.com',  '2023-07-01'),
(3, N'Lucía Gómez',  N'lucia@example.com', '2023-08-20');

INSERT INTO instructors (instructor_id, name, expertise) VALUES
(201, N'Carlos Díaz',  N'SQL y Bases de Datos'),
(202, N'María Torres', N'Machine Learning');

INSERT INTO courses (course_id, title, category, published_date) VALUES
(101, N'Introducción a SQL',          N'Data Science', '2023-01-10'),
(102, N'Machine Learning con Python', N'AI',           '2023-04-22'),
(103, N'Visualización de Datos',      N'Data Viz',     '2023-06-30');

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
