-- =========================================================
-- TAREA 4: ÍNDICE COMPUESTO (COVERING INDEX)
-- =========================================================
PRINT '=== TAREA 4: Índice compuesto con columnas incluidas ===';

-- Eliminar índice simple anterior SI EXISTE
IF EXISTS (SELECT 1 FROM sys.indexes 
           WHERE name = 'IX_partidos_fecha' 
           AND object_id = OBJECT_ID('dbo.partidos'))
BEGIN
    PRINT 'Eliminando índice simple anterior...';
    DROP INDEX IX_partidos_fecha ON dbo.partidos;
    PRINT 'Índice simple eliminado.';
END
ELSE
BEGIN
    PRINT 'El índice simple no existe (ya fue eliminado).';
END

-- Eliminar índice compuesto SI YA EXISTE
IF EXISTS (SELECT 1 FROM sys.indexes 
           WHERE name = 'IX_partidos_fecha_compuesto' 
           AND object_id = OBJECT_ID('dbo.partidos'))
BEGIN
    PRINT 'Eliminando índice compuesto existente...';
    DROP INDEX IX_partidos_fecha_compuesto ON dbo.partidos;
    PRINT 'Índice compuesto eliminado.';
END

-- Crear índice compuesto optimizado
PRINT 'Creando índice compuesto optimizado...';
CREATE INDEX IX_partidos_fecha_compuesto 
ON dbo.partidos(fecha_utc, estado)
INCLUDE (equipo_local, equipo_visitante, goles_local, goles_visitante);
PRINT 'Índice compuesto creado exitosamente.';
PRINT '-----------------------------------------------------';

-- Probar consultas optimizadas
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS XML ON;  
GO

-- Consulta 1: Búsqueda por período de fecha
PRINT 'Consulta 1: Partidos en 2023 (CON índice)';
SELECT COUNT(*) AS total_partidos_2023
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01';

-- Consulta 1: Partidos finalizados por período
PRINT 'Consulta con índice compuesto 1: Partidos finalizados por período';
SELECT 
    p.fecha_utc,
    p.estado,
    p.equipo_local,
    p.equipo_visitante,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-04-01'
  AND p.estado = 2;

-- Consulta 2: Búsqueda más específica con JOINs
PRINT 'Consulta 2: Partidos finalizados en Q1 2024 (CON índice)';
SELECT 
    p.id,
    p.fecha_utc,
    CASE p.estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
INNER JOIN dbo.equipos el ON p.equipo_local = el.id
INNER JOIN dbo.equipos ev ON p.equipo_visitante = ev.id
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-04-01'
  AND p.estado = 2;

-- Consulta 3: Agregación por mes
PRINT 'Consulta 3: Partidos por mes en 2023 (CON índice)';
SELECT 
    YEAR(fecha_utc) AS anio,
    MONTH(fecha_utc) AS mes,
    COUNT(*) AS total_partidos,
    SUM(CASE WHEN estado = 2 THEN 1 ELSE 0 END) AS finalizados
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01'
GROUP BY YEAR(fecha_utc), MONTH(fecha_utc)
ORDER BY anio, mes;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
SET STATISTICS XML OFF;  
GO

PRINT '=====================================================';
GO
