-- =========================================================
-- Tema 4: Vistas Indexadas - Tribuneros
-- Fecha: 2025-11-04
-- Descripción:
--   Crea una vista indexada que provee el conteo de partidos por liga y año.
--   La vista contiene únicamente (liga_id, anio, cantidad_partidos).
--   Si se necesitan MIN/MAX de fecha, se obtienen en las consultas mediante
--   OUTER APPLY o subconsultas adicionales.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================
-- Opciones SET requeridas para crear vistas indexadas
-- (según documentación oficial de Microsoft)
-- =========================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET ARITHABORT ON;
GO

-- =========================================
-- Eliminar índice y vista anteriores (si existen)
-- =========================================

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_vw_partidos_por_liga_y_anio'
      AND object_id = OBJECT_ID(N'dbo.vw_partidos_por_liga_y_anio')
)
BEGIN
    DROP INDEX IX_vw_partidos_por_liga_y_anio ON dbo.vw_partidos_por_liga_y_anio;
END
GO

IF OBJECT_ID('dbo.vw_partidos_por_liga_y_anio', 'V') IS NOT NULL
    DROP VIEW dbo.vw_partidos_por_liga_y_anio;
GO

-- =========================================
-- Crear vista indexada
-- Nota:
--   En este diseño la vista sólo almacena el conteo de partidos.
--   Otros agregados como MIN/MAX se calculan en las consultas de prueba
--   usando OUTER APPLY para mantener la vista lo más simple posible.
-- =========================================
CREATE VIEW dbo.vw_partidos_por_liga_y_anio
WITH SCHEMABINDING
AS
    SELECT
        p.liga_id,
        YEAR(p.fecha_utc) AS anio,
        COUNT_BIG(*)      AS cantidad_partidos
    FROM dbo.partidos AS p
    GROUP BY p.liga_id, YEAR(p.fecha_utc);
GO

-- Crear índice clustered único sobre la vista (clave: liga_id, anio)
CREATE UNIQUE CLUSTERED INDEX IX_vw_partidos_por_liga_y_anio
    ON dbo.vw_partidos_por_liga_y_anio (liga_id, anio);
GO

-- Comentarios:
--  - SCHEMABINDING evita cambios que rompan la vista y es requerido
--    para vistas indexadas.
--  - COUNT_BIG es obligatorio para agregaciones indexadas.
--  - El índice clustered materializa el resultado de la vista, de modo que
--    consultas que pidan "cantidad de partidos por liga y año" pueden leer
--    directamente del índice, ahorrando agrupaciones sobre dbo.partidos.
--
--  Para obtener fecha mínima y máxima por grupo se puede usar, por ejemplo:
--
--  SELECT
--      v.liga_id,
--      v.anio,
--      v.cantidad_partidos,
--      minp.fecha_minima_utc,
--      maxp.fecha_maxima_utc
--  FROM dbo.vw_partidos_por_liga_y_anio AS v
--  OUTER APPLY (
--      SELECT TOP (1) p.fecha_utc AS fecha_minima_utc
--      FROM dbo.partidos AS p
--      WHERE p.liga_id = v.liga_id AND YEAR(p.fecha_utc) = v.anio
--      ORDER BY p.fecha_utc ASC
--  ) AS minp
--  OUTER APPLY (
--      SELECT TOP (1) p.fecha_utc AS fecha_maxima_utc
--      FROM dbo.partidos AS p
--      WHERE p.liga_id = v.liga_id AND YEAR(p.fecha_utc) = v.anio
--      ORDER BY p.fecha_utc DESC
--  ) AS maxp;
