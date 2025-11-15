-- =========================================================
-- TAREA 4: ÍNDICE COMPUESTO (COVERING INDEX)
-- =========================================================

PRINT '=== TAREA 4: Índice compuesto con columnas incluidas ===';

-- Eliminar índice simple anterior
DROP INDEX IX_partidos_fecha ON dbo.partidos;

-- Crear índice compuesto que incluya las columnas más consultadas
PRINT 'Creando índice compuesto optimizado...';
CREATE INDEX IX_partidos_fecha_compuesto 
ON dbo.partidos(fecha_utc, estado)
INCLUDE (liga_id, equipo_local, equipo_visitante, goles_local, goles_visitante, estadio);

PRINT 'Índice compuesto creado.';
PRINT '-----------------------------------------------------';

-- Probar consultas optimizadas
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
SET STATISTICS XML ON;  
GO

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

PRINT 'Consulta con índice compuesto 2: Estadísticas de goles por estado';
SELECT 
    CASE estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    COUNT(*) AS total_partidos,
    AVG(CAST(goles_local + goles_visitante AS FLOAT)) AS promedio_goles
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01'
  AND goles_local IS NOT NULL 
  AND goles_visitante IS NOT NULL
GROUP BY estado;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
SET STATISTICS XML OFF;  
GO

PRINT '=====================================================';
GO