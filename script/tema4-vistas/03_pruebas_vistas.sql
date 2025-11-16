-- =========================================================
-- Tema 4: Pruebas de rendimiento - Vistas indexadas
-- Fecha: 2025-11-04
-- Objetivo:
--   Comparar rendimiento entre la consulta directa sobre dbo.partidos
--   y la lectura desde la vista indexada dbo.vw_partidos_por_liga_y_anio.
--   La vista indexada contiene sólo (liga_id, anio, cantidad_partidos);
--   las fechas mínima/máxima se obtienen con OUTER APPLY.
-- =========================================================

USE tribuneros_bdi;
GO

-- Activar estadísticas de IO y TIME
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- =========================================
-- BLOQUE A: Consulta directa sobre dbo.partidos
-- Agrupa por liga_id y año de fecha_utc.
-- =========================================
PRINT '--- BLOQUE A: Consulta directa sobre dbo.partidos (GROUP BY liga_id, YEAR(fecha_utc)) ---';

SELECT
    p.liga_id,
    YEAR(p.fecha_utc) AS anio,
    COUNT(*)          AS cantidad_partidos
FROM dbo.partidos AS p
GROUP BY
    p.liga_id,
    YEAR(p.fecha_utc)
ORDER BY
    p.liga_id,
    anio;
GO

-- Nota: guardar el plan de ejecución y la salida de STATISTICS IO/TIME
-- para el Bloque A.

-- =========================================
-- BLOQUE B: USANDO la vista indexada
-- La vista indexada dbo.vw_partidos_por_liga_y_anio contiene:
--   (liga_id, anio, cantidad_partidos)
-- =========================================
PRINT '--- BLOQUE B: Lectura desde dbo.vw_partidos_por_liga_y_anio (vista indexada) ---';

SELECT
    v.liga_id,
    v.anio,
    v.cantidad_partidos
FROM dbo.vw_partidos_por_liga_y_anio AS v
ORDER BY
    v.liga_id,
    v.anio;
GO

-- Nota: guardar el plan de ejecución y la salida de STATISTICS IO/TIME
-- para el Bloque B.

-- =========================================
-- BLOQUE B2: Lectura desde la vista indexada + OUTER APPLY para MIN/MAX
-- Esta variante usa OUTER APPLY para obtener la fecha mínima y máxima por grupo.
-- =========================================
PRINT '--- BLOQUE B2: Lectura desde la vista indexada + OUTER APPLY para MIN/MAX ---';

SELECT
    v.liga_id,
    v.anio,
    v.cantidad_partidos,
    minp.fecha_minima_utc,
    maxp.fecha_maxima_utc
FROM dbo.vw_partidos_por_liga_y_anio AS v
OUTER APPLY (
    SELECT TOP (1) p.fecha_utc AS fecha_minima_utc
    FROM dbo.partidos AS p
    WHERE p.liga_id = v.liga_id
      AND YEAR(p.fecha_utc) = v.anio
    ORDER BY p.fecha_utc ASC
) AS minp
OUTER APPLY (
    SELECT TOP (1) p.fecha_utc AS fecha_maxima_utc
    FROM dbo.partidos AS p
    WHERE p.liga_id = v.liga_id
      AND YEAR(p.fecha_utc) = v.anio
    ORDER BY p.fecha_utc DESC
) AS maxp
ORDER BY
    v.liga_id,
    v.anio;
GO

-- =========================================
-- BLOQUE B3: Vista indexada + join con ligas
-- Ejemplo de lookup típico: cantidad de partidos por liga y año con nombre de liga.
-- =========================================
PRINT '--- BLOQUE B3: Vista indexada + JOIN ligas (liga_nombre) ---';

SELECT
    l.id         AS liga_id,
    l.nombre     AS liga_nombre,
    v.anio,
    v.cantidad_partidos
FROM dbo.vw_partidos_por_liga_y_anio AS v
JOIN dbo.ligas AS l
    ON l.id = v.liga_id
ORDER BY
    l.id,
    v.anio;
GO

-- Apagar estadísticas si se desea (opcional)
-- SET STATISTICS IO OFF;
-- SET STATISTICS TIME OFF;
-- GO

-- Instrucciones:
--  - Ejecutar cada bloque y guardar:
--      * Plan de ejecución (.sqlplan).
--      * Salida completa de STATISTICS IO/TIME.
--  - Comparar lecturas lógicas y tiempos entre:
--      * Bloque A (consulta directa sobre dbo.partidos).
--      * Bloque B (lectura desde la vista indexada).
--  - Bloque B2 y B3 muestran cómo reutilizar la vista indexada
--    en consultas un poco más ricas (MIN/MAX y join con ligas).
