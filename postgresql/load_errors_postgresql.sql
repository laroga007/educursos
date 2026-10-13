-- =====================================================
-- EduCursos - Tabla de errores de carga (PostgreSQL)
-- Guarda cada registro rechazado durante una carga,
-- con su origen, el motivo y el momento: trazabilidad.
-- Ejecutar conectada a la base educursos
-- =====================================================

DROP TABLE IF EXISTS load_errors;

CREATE TABLE load_errors (
    error_id       INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source         VARCHAR(100)  NOT NULL,   -- archivo o API de origen
    record         TEXT          NOT NULL,   -- el registro rechazado, tal como llegó
    error_message  TEXT          NOT NULL,   -- por qué se rechazó
    loaded_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
