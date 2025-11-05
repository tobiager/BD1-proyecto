-- =========================================================
-- TAREA 5: COMPARACIÓN Y DOCUMENTACIÓN DE PLAN DE EJECUCIÓN
-- =========================================================

USE tribuneros_bdi;
GO


PRINT '=== TAREA 5: Plan de ejecución y análisis ===';
PRINT 'Para ver el plan de ejecución:';
PRINT '1. Presiona Ctrl+M en SSMS antes de ejecutar';
PRINT '2. Ejecuta la consulta siguiente';
PRINT '3. Revisa la pestaña "Execution Plan"';
PRINT '-----------------------------------------------------';

-- Consulta para analizar plan de ejecución
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
    l.nombre AS liga,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    p.goles_local,
    p.goles_visitante,
    p.estadio
FROM dbo.partidos p
INNER JOIN dbo.ligas l ON p.liga_id = l.id
INNER JOIN dbo.equipos el ON p.equipo_local = el.id
INNER JOIN dbo.equipos ev ON p.equipo_visitante = ev.id
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-06-01'
  AND p.estado = 2
ORDER BY p.fecha_utc DESC;

PRINT '=====================================================';
GO