-- =========================================================
-- TAREA 3: CREAR ÍNDICE Y REPETIR CONSULTAS
-- =========================================================

PRINT '=== TAREA 3: Crear índice y medir mejora ===';

-- Crear índice en fecha_utc
PRINT 'Creando índice IX_partidos_fecha...';
DECLARE @inicio_idx DATETIME2 = SYSDATETIME();

CREATE INDEX IX_partidos_fecha ON dbo.partidos(fecha_utc);

DECLARE @fin_idx DATETIME2 = SYSDATETIME();
PRINT 'Índice creado en: ' + CAST(DATEDIFF(SECOND, @inicio_idx, @fin_idx) AS VARCHAR(20)) + ' segundos';
PRINT '-----------------------------------------------------';

-- Repetir las mismas consultas CON índice
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT 'Consulta 1: Partidos en 2023 (CON índice)';
SELECT COUNT(*) AS total_partidos_2023
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01';

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

PRINT '=====================================================';
GO