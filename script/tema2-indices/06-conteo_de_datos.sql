USE tribuneros_bdi;
GO

-- =========================================================
-- CONSULTAS ADICIONALES PARA EVALUACIÓN
-- =========================================================

PRINT '=== Consultas de verificación ===';

-- Verificar conteos exactos
SELECT 'usuarios' AS tabla, COUNT(*) AS registros FROM dbo.usuarios
UNION ALL
SELECT 'perfiles', COUNT(*) FROM dbo.perfiles
UNION ALL
SELECT 'ligas', COUNT(*) FROM dbo.ligas
UNION ALL
SELECT 'equipos', COUNT(*) FROM dbo.equipos
UNION ALL
SELECT 'partidos', COUNT(*) FROM dbo.partidos
UNION ALL
SELECT 'calificaciones', COUNT(*) FROM dbo.calificaciones
UNION ALL
SELECT 'favoritos', COUNT(*) FROM dbo.favoritos
UNION ALL
SELECT 'visualizaciones', COUNT(*) FROM dbo.visualizaciones
UNION ALL
SELECT 'opiniones', COUNT(*) FROM dbo.opiniones;

-- Ver índices creados en partidos
SELECT 
    i.name AS nombre_indice,
    i.type_desc AS tipo,
    COL_NAME(ic.object_id, ic.column_id) AS columna,
    ic.is_included_column AS es_incluida
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('dbo.partidos')
ORDER BY i.name, ic.key_ordinal;

-- Estadísticas de partidos por estado
SELECT 
    CASE estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    COUNT(*) AS cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.partidos) AS DECIMAL(5,2)) AS porcentaje
FROM dbo.partidos
GROUP BY estado
ORDER BY estado;

PRINT '=====================================================';
GO