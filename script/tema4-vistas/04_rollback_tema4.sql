-- =========================================================
-- Tema 4: Rollback / limpieza - Tribuneros
-- Autor: [Tu Nombre Aquí]
-- Fecha: 2025-11-04
-- Descripción:
--   Revierte los cambios introducidos en el Tema 4 (vistas, índices, datos de prueba).
--   Advertencia: borra únicamente los registros de prueba insertados por los scripts
--   de este tema (ids 9000..9009). No modifica los datos oficiales del proyecto.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================
-- 1) Eliminar índice y vista indexada
-- =========================================
PRINT '--- 1) Eliminando índice y vista indexada (si existen) ---';

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_vw_partidos_por_liga_y_anio'
      AND object_id = OBJECT_ID(N'dbo.vw_partidos_por_liga_y_anio')
)
BEGIN
    DROP INDEX IX_vw_partidos_por_liga_y_anio ON dbo.vw_partidos_por_liga_y_anio;
    PRINT 'Índice IX_vw_partidos_por_liga_y_anio eliminado.';
END
ELSE
    PRINT 'Índice IX_vw_partidos_por_liga_y_anio no existe.';

IF OBJECT_ID('dbo.vw_partidos_por_liga_y_anio', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.vw_partidos_por_liga_y_anio;
    PRINT 'Vista dbo.vw_partidos_por_liga_y_anio eliminada.';
END
ELSE
    PRINT 'Vista dbo.vw_partidos_por_liga_y_anio no existe.';
GO

-- =========================================
-- 2) Eliminar vista simple (vw_partidos_basicos)
-- =========================================
PRINT '--- 2) Eliminando vista simple vw_partidos_basicos si existe ---';

IF OBJECT_ID('dbo.vw_partidos_basicos', 'V') IS NOT NULL
BEGIN
    DROP VIEW dbo.vw_partidos_basicos;
    PRINT 'Vista dbo.vw_partidos_basicos eliminada.';
END
ELSE
    PRINT 'Vista dbo.vw_partidos_basicos no existe.';
GO

-- =========================================
-- 3) Borrar datos de prueba en dbo.partidos
--    (Sólo registros creados por los scripts del Tema 4: id BETWEEN 9000 AND 9009)
-- =========================================
PRINT '--- 3) Borrando datos de prueba en dbo.partidos (id 9000..9009) ---';

-- Verificación previa
SELECT COUNT(*) AS cantidad_prueba_antes
FROM dbo.partidos
WHERE id BETWEEN 9000 AND 9009;

-- Borrado controlado
DELETE FROM dbo.partidos
WHERE id BETWEEN 9000 AND 9009;

-- Verificación posterior
SELECT COUNT(*) AS cantidad_prueba_despues
FROM dbo.partidos
WHERE id BETWEEN 9000 AND 9009;
GO

PRINT 'Rollback del Tema 4 completado. La base debe quedar en el estado definido por creacion.sql y carga_inicial.sql (salvo datos adicionales creados por otros scripts).';
