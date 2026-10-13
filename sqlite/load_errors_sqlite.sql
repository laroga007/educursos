-- =====================================================
-- EduCursos - Tabla de errores de carga (SQLite)
-- =====================================================

DROP TABLE IF EXISTS load_errors;

CREATE TABLE load_errors (
    error_id       INTEGER  PRIMARY KEY AUTOINCREMENT,
    source         TEXT     NOT NULL,
    record         TEXT     NOT NULL,
    error_message  TEXT     NOT NULL,
    loaded_at      TEXT     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
