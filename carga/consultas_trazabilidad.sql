-- =====================================================
-- EduCursos - Consultas para revisar una carga
-- (SQL estándar: funcionan igual en los 4 motores)
-- =====================================================

-- 1) Todos los registros rechazados, del más reciente al más viejo
SELECT error_id, source, record, error_message, loaded_at
FROM load_errors
ORDER BY loaded_at DESC, error_id DESC;

-- 2) Cuántos errores hubo por origen
SELECT source, COUNT(*) AS errores
FROM load_errors
GROUP BY source;

-- 3) Cómo quedaron las tablas después de la carga
--    Esperado: users 5, subscriptions 7
SELECT 'users' AS tabla, COUNT(*) AS filas FROM users
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions;
