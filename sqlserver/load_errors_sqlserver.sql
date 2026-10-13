-- =====================================================
-- EduCursos - Tabla de errores de carga (SQL Server)
-- Ejecutar conectada a la base educursos
-- =====================================================

DROP TABLE IF EXISTS load_errors;

CREATE TABLE load_errors (
    error_id       INT            IDENTITY(1,1) PRIMARY KEY,
    source         NVARCHAR(100)  NOT NULL,
    record         NVARCHAR(MAX)  NOT NULL,
    error_message  NVARCHAR(MAX)  NOT NULL,
    loaded_at      DATETIME2      NOT NULL DEFAULT CURRENT_TIMESTAMP
);
