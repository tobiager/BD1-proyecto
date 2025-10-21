-- =========================================================
-- TEMA 3: Optimización con Índices
-- Script 1: Carga Masiva de Datos
-- =========================================================
-- Este script genera 1,000,000+ registros de partidos para
-- realizar pruebas de performance con índices.
-- ADVERTENCIA: Esta operación puede tomar varios minutos.
-- =========================================================

USE tribuneros_bdi;
GO

SET NOCOUNT ON;
GO

PRINT '==================================================';
PRINT 'CARGA MASIVA DE DATOS PARA PRUEBAS DE ÍNDICES';
PRINT '==================================================';
PRINT '';
PRINT 'ADVERTENCIA: Este proceso insertará 1,000,000+ registros.';
PRINT 'Tiempo estimado: 5-15 minutos dependiendo del hardware.';
PRINT '';

-- =========================================================
-- SECCIÓN 1: Preparación
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 1: PREPARACIÓN';
PRINT '==================================================';
PRINT '';

-- Verificar si ya existen datos de carga masiva
DECLARE @registros_existentes INT;
SELECT @registros_existentes = COUNT(*) FROM dbo.partidos WHERE id >= 1000000;

IF @registros_existentes > 0
BEGIN
    PRINT 'Se encontraron ' + CAST(@registros_existentes AS VARCHAR(10)) + ' registros de carga masiva anteriores.';
    PRINT 'Eliminando datos anteriores...';
    DELETE FROM dbo.partidos WHERE id >= 1000000;
    PRINT 'Datos anteriores eliminados.';
    PRINT '';
END

-- Verificar que existen equipos
DECLARE @equipo_local INT, @equipo_visitante INT;
SELECT TOP 1 @equipo_local = id FROM dbo.equipos ORDER BY id;
SELECT @equipo_visitante = id FROM dbo.equipos WHERE id > @equipo_local ORDER BY id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

IF @equipo_local IS NULL OR @equipo_visitante IS NULL
BEGIN
    PRINT 'ERROR: Se necesitan al menos 2 equipos en la base de datos.';
    RETURN;
END

PRINT 'Equipos seleccionados para carga masiva:';
PRINT '  - Equipo local: ' + CAST(@equipo_local AS VARCHAR(10));
PRINT '  - Equipo visitante: ' + CAST(@equipo_visitante AS VARCHAR(10));
PRINT '';

-- =========================================================
-- SECCIÓN 2: Carga Masiva de 1,000,000 Registros
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 2: INICIANDO CARGA MASIVA';
PRINT '==================================================';
PRINT '';
PRINT 'Insertando 1,000,000 registros en lotes de 10,000...';
PRINT 'Por favor espere, esto puede tardar varios minutos.';
PRINT '';

DECLARE @inicio DATETIME2 = SYSDATETIME();
DECLARE @lote INT = 0;
DECLARE @total_registros INT = 1000000;
DECLARE @registros_por_lote INT = 10000;
DECLARE @total_lotes INT = @total_registros / @registros_por_lote;

-- Usar fecha base para generar diferentes fechas
DECLARE @fecha_base DATETIME2 = '2020-01-01';

-- Desactivar restricciones temporalmente para mayor velocidad
ALTER TABLE dbo.partidos NOCHECK CONSTRAINT ALL;

-- Insertar en lotes
WHILE @lote < @total_lotes
BEGIN
    DECLARE @id_inicial INT = 1000000 + (@lote * @registros_por_lote);
    DECLARE @id_final INT = @id_inicial + @registros_por_lote - 1;
    
    -- Insertar lote usando tabla de números
    ;WITH Numeros AS (
        SELECT TOP (@registros_por_lote) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_columns c1
        CROSS JOIN sys.all_columns c2
    )
    INSERT INTO dbo.partidos (
        id, liga_id, temporada, ronda, fecha_utc, estado, estadio,
        equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
    )
    SELECT
        @id_inicial + n,
        1,
        2020 + (n % 5),  -- Temporadas 2020-2024
        'Fecha ' + CAST((n % 38) + 1 AS VARCHAR(10)),  -- 38 fechas
        DATEADD(DAY, n % 1826, @fecha_base),  -- Distribuir en 5 años (1826 días)
        CASE (n % 5)
            WHEN 0 THEN 'finalizado'
            WHEN 1 THEN 'programado'
            WHEN 2 THEN 'en_vivo'
            WHEN 3 THEN 'finalizado'
            ELSE 'pospuesto'
        END,
        'Estadio ' + CAST((n % 50) + 1 AS VARCHAR(10)),  -- 50 estadios diferentes
        @equipo_local,
        @equipo_visitante,
        CASE WHEN (n % 5) IN (0, 3) THEN (n % 6) ELSE NULL END,  -- Goles si está finalizado
        CASE WHEN (n % 5) IN (0, 3) THEN (n % 5) ELSE NULL END,
        SYSDATETIME()
    FROM Numeros;
    
    SET @lote = @lote + 1;
    
    -- Mostrar progreso cada 10 lotes (100,000 registros)
    IF @lote % 10 = 0
    BEGIN
        DECLARE @progreso DECIMAL(5,2) = (@lote * 100.0) / @total_lotes;
        DECLARE @registros_insertados INT = @lote * @registros_por_lote;
        PRINT 'Progreso: ' + CAST(@progreso AS VARCHAR(10)) + '% (' + 
              CAST(@registros_insertados AS VARCHAR(10)) + ' registros insertados)';
    END
END

-- Reactivar restricciones
ALTER TABLE dbo.partidos WITH CHECK CHECK CONSTRAINT ALL;

DECLARE @fin DATETIME2 = SYSDATETIME();
DECLARE @duracion_segundos INT = DATEDIFF(SECOND, @inicio, @fin);
DECLARE @duracion_minutos DECIMAL(5,2) = @duracion_segundos / 60.0;

PRINT '';
PRINT '==================================================';
PRINT 'CARGA MASIVA COMPLETADA';
PRINT '==================================================';
PRINT '';
PRINT 'Estadísticas de carga:';
PRINT '  - Registros insertados: ' + CAST(@total_registros AS VARCHAR(10));
PRINT '  - Tiempo total: ' + CAST(@duracion_segundos AS VARCHAR(10)) + ' segundos (' + 
      CAST(@duracion_minutos AS VARCHAR(10)) + ' minutos)';
PRINT '  - Velocidad: ' + CAST(@total_registros / @duracion_segundos AS VARCHAR(10)) + ' registros/segundo';
PRINT '';

-- =========================================================
-- SECCIÓN 3: Verificación de Datos
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 3: VERIFICACIÓN DE DATOS';
PRINT '==================================================';
PRINT '';

-- Contar registros totales
DECLARE @total_partidos INT;
SELECT @total_partidos = COUNT(*) FROM dbo.partidos;
PRINT 'Total de partidos en la tabla: ' + CAST(@total_partidos AS VARCHAR(10));

-- Contar registros de carga masiva
DECLARE @partidos_carga_masiva INT;
SELECT @partidos_carga_masiva = COUNT(*) FROM dbo.partidos WHERE id >= 1000000;
PRINT 'Partidos de carga masiva: ' + CAST(@partidos_carga_masiva AS VARCHAR(10));
PRINT '';

-- Distribución por estado
PRINT 'Distribución de partidos por estado:';
SELECT 
    estado,
    COUNT(*) AS cantidad,
    CAST(COUNT(*) * 100.0 / @partidos_carga_masiva AS DECIMAL(5,2)) AS porcentaje
FROM dbo.partidos
WHERE id >= 1000000
GROUP BY estado
ORDER BY cantidad DESC;
PRINT '';

-- Rango de fechas
PRINT 'Rango de fechas en los datos de prueba:';
SELECT 
    MIN(fecha_utc) AS fecha_minima,
    MAX(fecha_utc) AS fecha_maxima,
    DATEDIFF(DAY, MIN(fecha_utc), MAX(fecha_utc)) AS dias_total
FROM dbo.partidos
WHERE id >= 1000000;
PRINT '';

-- Distribución por año
PRINT 'Distribución de partidos por año:';
SELECT 
    YEAR(fecha_utc) AS anio,
    COUNT(*) AS cantidad
FROM dbo.partidos
WHERE id >= 1000000
GROUP BY YEAR(fecha_utc)
ORDER BY anio;
PRINT '';

-- =========================================================
-- SECCIÓN 4: Información del Sistema
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 4: INFORMACIÓN DEL SISTEMA';
PRINT '==================================================';
PRINT '';

-- Tamaño de la tabla
PRINT 'Información de almacenamiento:';
SELECT 
    t.name AS tabla,
    p.rows AS filas,
    SUM(a.total_pages) * 8 AS tamano_kb,
    SUM(a.total_pages) * 8 / 1024 AS tamano_mb,
    SUM(a.used_pages) * 8 AS usado_kb,
    SUM(a.total_pages - a.used_pages) * 8 AS libre_kb
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.name = 'partidos'
GROUP BY t.name, p.rows;
PRINT '';

-- =========================================================
-- SECCIÓN 5: Preparación para Pruebas de Performance
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 5: PREPARACIÓN PARA PRUEBAS';
PRINT '==================================================';
PRINT '';

PRINT 'Datos listos para pruebas de índices.';
PRINT '';
PRINT 'Próximos pasos:';
PRINT '  1. Ejecutar consultas sin índices (script 02_Pruebas_Performance.sql)';
PRINT '  2. Crear índice clustered simple';
PRINT '  3. Crear índice clustered con columnas incluidas';
PRINT '  4. Comparar planes de ejecución y tiempos';
PRINT '';
PRINT 'NOTA: Antes de ejecutar las pruebas, es recomendable:';
PRINT '  - Limpiar la caché de planes: DBCC FREEPROCCACHE';
PRINT '  - Limpiar el buffer pool: DBCC DROPCLEANBUFFERS';
PRINT '  - Actualizar estadísticas: UPDATE STATISTICS dbo.partidos';
PRINT '';

-- Actualizar estadísticas
UPDATE STATISTICS dbo.partidos;
PRINT 'Estadísticas actualizadas.';
PRINT '';

PRINT '==================================================';
PRINT 'Script de carga masiva completado exitosamente.';
PRINT '==================================================';
GO
