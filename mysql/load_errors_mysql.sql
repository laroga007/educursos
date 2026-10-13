-- =====================================================
-- EduCursos - Tabla de errores de carga (MySQL)
-- =====================================================

USE educursos;

DROP TABLE IF EXISTS load_errors;

CREATE TABLE load_errors (
    error_id       INT           AUTO_INCREMENT PRIMARY KEY,
    source         VARCHAR(100)  NOT NULL,
    record         TEXT          NOT NULL,
    error_message  TEXT          NOT NULL,
    loaded_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
