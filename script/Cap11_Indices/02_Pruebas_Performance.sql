-- =========================================================
-- TEMA 3: Optimización con Índices
-- Script 2: Pruebas de Performance con Índices
-- =========================================================
-- Este script realiza pruebas comparativas de consultas
-- con diferentes estrategias de indexación.
-- =========================================================

USE tribuneros_bdi;
GO

SET NOCOUNT ON;
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

PRINT '==================================================';
PRINT 'PRUEBAS DE PERFORMANCE CON ÍNDICES';
PRINT '==================================================';
PRINT '';
PRINT 'Este script compara el rendimiento de consultas con:';
PRINT '  1. Sin índice adicional (solo PK)';
PRINT '  2. Índice no agrupado en fecha_utc';
PRINT '  3. Índice no agrupado con columnas incluidas';
PRINT '';

-- =========================================================
-- SECCIÓN 1: Preparación
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 1: PREPARACIÓN';
PRINT '==================================================';
PRINT '';

-- Verificar que existen datos de carga masiva
DECLARE @registros_carga INT;
SELECT @registros_carga = COUNT(*) FROM dbo.partidos WHERE id >= 1000000;

IF @registros_carga < 100000
BEGIN
    PRINT 'ERROR: Se necesitan al menos 100,000 registros de carga masiva.';
    PRINT 'Ejecute primero el script 01_Carga_Masiva.sql';
    RETURN;
END

PRINT 'Registros disponibles: ' + CAST(@registros_carga AS VARCHAR(10));
PRINT '';

-- Eliminar índices de prueba si existen
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_partidos_fecha_test' AND object_id = OBJECT_ID('dbo.partidos'))
BEGIN
    DROP INDEX IX_partidos_fecha_test ON dbo.partidos;
    PRINT 'Índice de prueba anterior eliminado.';
END

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_partidos_fecha_incluido_test' AND object_id = OBJECT_ID('dbo.partidos'))
BEGIN
    DROP INDEX IX_partidos_fecha_incluido_test ON dbo.partidos;
    PRINT 'Índice con columnas incluidas anterior eliminado.';
END
PRINT '';

-- Limpiar caché y actualizar estadísticas
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
UPDATE STATISTICS dbo.partidos;
PRINT 'Caché limpiada y estadísticas actualizadas.';
PRINT '';

-- =========================================================
-- SECCIÓN 2: PRUEBA 1 - Sin Índice Adicional
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 1: CONSULTA SIN ÍNDICE ADICIONAL';
PRINT '==================================================';
PRINT '';
PRINT 'Consulta: Partidos en un rango de 30 días';
PRINT 'Índices disponibles: Solo PK (clustered en id)';
PRINT '';
PRINT '--- INICIO PRUEBA 1 ---';
GO

-- Activar plan de ejecución real
SET STATISTICS XML ON;

-- Consulta de prueba: Partidos en un rango de fechas específico
DECLARE @fecha_inicio DATETIME2 = '2022-01-01';
DECLARE @fecha_fin DATETIME2 = '2022-01-31';
DECLARE @inicio DATETIME2 = SYSDATETIME();

SELECT 
    p.id,
    p.fecha_utc,
    p.estado,
    p.estadio,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
WHERE p.fecha_utc BETWEEN @fecha_inicio AND @fecha_fin
    AND p.id >= 1000000
ORDER BY p.fecha_utc;

DECLARE @fin DATETIME2 = SYSDATETIME();
DECLARE @duracion_ms_1 INT = DATEDIFF(MILLISECOND, @inicio, @fin);

SET STATISTICS XML OFF;

PRINT '';
PRINT '--- FIN PRUEBA 1 ---';
PRINT 'Tiempo de ejecución: ' + CAST(@duracion_ms_1 AS VARCHAR(10)) + ' ms';
PRINT '';
PRINT 'Observaciones:';
PRINT '  - Se espera un Table Scan o Clustered Index Scan';
PRINT '  - Alto número de lecturas lógicas';
PRINT '  - Tiempo de respuesta más lento';
PRINT '';

GO

-- Limpiar caché entre pruebas
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
WAITFOR DELAY '00:00:02';

-- =========================================================
-- SECCIÓN 3: PRUEBA 2 - Índice No Agrupado Simple
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 2: ÍNDICE NO AGRUPADO SIMPLE';
PRINT '==================================================';
PRINT '';
PRINT 'Creando índice no agrupado en fecha_utc...';
GO

-- Crear índice no agrupado en fecha_utc
CREATE NONCLUSTERED INDEX IX_partidos_fecha_test
ON dbo.partidos(fecha_utc)
WHERE id >= 1000000;

PRINT 'Índice IX_partidos_fecha_test creado.';
PRINT '';

-- Actualizar estadísticas
UPDATE STATISTICS dbo.partidos IX_partidos_fecha_test;
PRINT 'Estadísticas del índice actualizadas.';
PRINT '';

PRINT 'Ejecutando consulta con índice...';
PRINT '';
PRINT '--- INICIO PRUEBA 2 ---';
GO

SET STATISTICS XML ON;

DECLARE @fecha_inicio2 DATETIME2 = '2022-01-01';
DECLARE @fecha_fin2 DATETIME2 = '2022-01-31';
DECLARE @inicio2 DATETIME2 = SYSDATETIME();

SELECT 
    p.id,
    p.fecha_utc,
    p.estado,
    p.estadio,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
WHERE p.fecha_utc BETWEEN @fecha_inicio2 AND @fecha_fin2
    AND p.id >= 1000000
ORDER BY p.fecha_utc;

DECLARE @fin2 DATETIME2 = SYSDATETIME();
DECLARE @duracion_ms_2 INT = DATEDIFF(MILLISECOND, @inicio2, @fin2);

SET STATISTICS XML OFF;

PRINT '';
PRINT '--- FIN PRUEBA 2 ---';
PRINT 'Tiempo de ejecución: ' + CAST(@duracion_ms_2 AS VARCHAR(10)) + ' ms';
PRINT '';
PRINT 'Observaciones:';
PRINT '  - Se espera un Index Seek en IX_partidos_fecha_test';
PRINT '  - Key Lookup para obtener columnas adicionales';
PRINT '  - Menor número de lecturas que Prueba 1';
PRINT '  - Tiempo mejorado, pero con overhead de Key Lookups';
PRINT '';

GO

-- Limpiar caché entre pruebas
DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
WAITFOR DELAY '00:00:02';

-- =========================================================
-- SECCIÓN 4: PRUEBA 3 - Índice con Columnas Incluidas
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 3: ÍNDICE CON COLUMNAS INCLUIDAS';
PRINT '==================================================';
PRINT '';
PRINT 'Eliminando índice anterior...';
GO

DROP INDEX IX_partidos_fecha_test ON dbo.partidos;
PRINT 'Índice anterior eliminado.';
PRINT '';

PRINT 'Creando índice con columnas incluidas...';
GO

-- Crear índice con columnas incluidas (COVERING INDEX)
CREATE NONCLUSTERED INDEX IX_partidos_fecha_incluido_test
ON dbo.partidos(fecha_utc)
INCLUDE (id, estado, estadio, goles_local, goles_visitante)
WHERE id >= 1000000;

PRINT 'Índice IX_partidos_fecha_incluido_test creado.';
PRINT 'Columnas incluidas: id, estado, estadio, goles_local, goles_visitante';
PRINT '';

-- Actualizar estadísticas
UPDATE STATISTICS dbo.partidos IX_partidos_fecha_incluido_test;
PRINT 'Estadísticas del índice actualizadas.';
PRINT '';

PRINT 'Ejecutando consulta con índice covering...';
PRINT '';
PRINT '--- INICIO PRUEBA 3 ---';
GO

SET STATISTICS XML ON;

DECLARE @fecha_inicio3 DATETIME2 = '2022-01-01';
DECLARE @fecha_fin3 DATETIME2 = '2022-01-31';
DECLARE @inicio3 DATETIME2 = SYSDATETIME();

SELECT 
    p.id,
    p.fecha_utc,
    p.estado,
    p.estadio,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
WHERE p.fecha_utc BETWEEN @fecha_inicio3 AND @fecha_fin3
    AND p.id >= 1000000
ORDER BY p.fecha_utc;

DECLARE @fin3 DATETIME2 = SYSDATETIME();
DECLARE @duracion_ms_3 INT = DATEDIFF(MILLISECOND, @inicio3, @fin3);

SET STATISTICS XML OFF;

PRINT '';
PRINT '--- FIN PRUEBA 3 ---';
PRINT 'Tiempo de ejecución: ' + CAST(@duracion_ms_3 AS VARCHAR(10)) + ' ms';
PRINT '';
PRINT 'Observaciones:';
PRINT '  - Se espera un Index Seek en IX_partidos_fecha_incluido_test';
PRINT '  - NO hay Key Lookups (covering index)';
PRINT '  - Mínimo número de lecturas lógicas';
PRINT '  - Mejor tiempo de respuesta';
PRINT '';

GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

-- =========================================================
-- SECCIÓN 5: Comparación de Resultados
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 5: COMPARACIÓN DE RESULTADOS';
PRINT '==================================================';
PRINT '';
PRINT 'RESUMEN DE PRUEBAS:';
PRINT '';
PRINT 'Nota: Los tiempos exactos varían según el hardware.';
PRINT 'Revise las estadísticas de IO y los planes de ejecución XML.';
PRINT '';
PRINT 'Resultados esperados:';
PRINT '';
PRINT '1. Sin índice adicional:';
PRINT '   - Operación: Table/Clustered Index Scan';
PRINT '   - Lecturas: ALTO (escanea toda la tabla)';
PRINT '   - Tiempo: LENTO';
PRINT '   - Costo estimado: ALTO';
PRINT '';
PRINT '2. Índice no agrupado simple:';
PRINT '   - Operación: Index Seek + Key Lookups';
PRINT '   - Lecturas: MEDIO (seek + lookups)';
PRINT '   - Tiempo: MEDIO';
PRINT '   - Costo estimado: MEDIO';
PRINT '';
PRINT '3. Índice con columnas incluidas:';
PRINT '   - Operación: Index Seek (covering)';
PRINT '   - Lecturas: BAJO (solo el índice)';
PRINT '   - Tiempo: RÁPIDO';
PRINT '   - Costo estimado: BAJO';
PRINT '';

-- =========================================================
-- SECCIÓN 6: Análisis de Índices
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 6: INFORMACIÓN DE ÍNDICES';
PRINT '==================================================';
PRINT '';

PRINT 'Índices en la tabla partidos:';
SELECT 
    i.name AS nombre_indice,
    i.type_desc AS tipo,
    i.is_unique AS es_unico,
    i.is_primary_key AS es_pk,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS columnas_clave,
    STUFF((
        SELECT ', ' + c.name
        FROM sys.index_columns ic
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH('')
    ), 1, 2, '') AS columnas_incluidas
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.partidos')
    AND i.type > 0  -- Excluir heap
ORDER BY i.index_id;
PRINT '';

-- Tamaño de índices
PRINT 'Tamaño de índices:';
SELECT 
    i.name AS nombre_indice,
    SUM(s.used_page_count) * 8 AS tamano_kb,
    SUM(s.used_page_count) * 8 / 1024 AS tamano_mb
FROM sys.dm_db_partition_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE s.object_id = OBJECT_ID('dbo.partidos')
GROUP BY i.name
ORDER BY tamano_kb DESC;
PRINT '';

-- =========================================================
-- SECCIÓN 7: Conclusiones y Recomendaciones
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 7: CONCLUSIONES';
PRINT '==================================================';
PRINT '';
PRINT 'Conclusiones clave:';
PRINT '';
PRINT '✓ Los índices mejoran significativamente el rendimiento de consultas';
PRINT '✓ Los índices covering (con INCLUDE) eliminan Key Lookups';
PRINT '✓ El costo de mantener índices se compensa con mejor lectura';
PRINT '✓ Los índices filtrados (WHERE) reducen el tamaño del índice';
PRINT '';
PRINT 'Recomendaciones:';
PRINT '';
PRINT '1. Crear índices en columnas usadas frecuentemente en WHERE y JOIN';
PRINT '2. Usar INCLUDE para columnas en SELECT que no están en WHERE';
PRINT '3. Considerar índices filtrados para subconjuntos específicos';
PRINT '4. Monitorear el uso de índices con DMVs';
PRINT '5. Eliminar índices no utilizados que solo consumen espacio';
PRINT '';
PRINT 'Trade-offs:';
PRINT '';
PRINT '- Mayor velocidad de lectura vs espacio en disco';
PRINT '- Mayor velocidad de lectura vs tiempo de escritura (INSERT/UPDATE)';
PRINT '- Índices covering vs mantenimiento y espacio';
PRINT '';

-- =========================================================
-- SECCIÓN 8: Limpieza (Opcional)
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 8: LIMPIEZA';
PRINT '==================================================';
PRINT '';
PRINT 'Para eliminar el índice de prueba, ejecute:';
PRINT 'DROP INDEX IX_partidos_fecha_incluido_test ON dbo.partidos;';
PRINT '';
PRINT 'Nota: Se recomienda mantener el índice si planea ejecutar';
PRINT 'consultas frecuentes por rango de fechas.';
PRINT '';

PRINT '==================================================';
PRINT 'Script de pruebas de performance completado.';
PRINT '==================================================';
PRINT '';
PRINT 'IMPORTANTE: Revise los planes de ejecución XML capturados';
PRINT 'durante cada prueba para un análisis detallado.';
PRINT '';
GO
