-- =========================================================
-- Tema 4: Vistas (Parte 1) - Tribuneros
-- Fecha: 2025-11-04
-- Descripción:
--   Crea una vista simple actualizable sobre dbo.partidos (vw_partidos_basicos)
--   y demuestra operaciones INSERT / UPDATE / DELETE a través de la vista.
-- =========================================================

USE tribuneros_bdi;
GO

-- Opciones requeridas para vistas (no indexada aquí)
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =========================================
-- SECCIÓN: Crear / recrear vista vw_partidos_basicos
-- =========================================
IF OBJECT_ID('dbo.vw_partidos_basicos', 'V') IS NOT NULL
    DROP VIEW dbo.vw_partidos_basicos;
GO

CREATE VIEW dbo.vw_partidos_basicos
AS
    -- Vista simple basada únicamente en dbo.partidos (sin joins)
    -- Expone columnas clave para operaciones CRUD simples desde capas de negocio:
    --   id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada
    -- Justificación:
    --   Estas columnas representan la información mínima necesaria para crear/editar
    --   partidos programados y permiten filtros/comparaciones por liga y fecha.
    SELECT
        id,
        liga_id,
        fecha_utc,
        equipo_local,
        equipo_visitante,
        estado,
        temporada
    FROM dbo.partidos;
GO

-- =========================================
-- SECCIÓN: Datos de prueba identificables
-- Estrategia de idempotencia:
--  - Inserciones de prueba usan id en rango 9000..9009 (muy por encima de los ids actuales)
--  - El rollback borrará únicamente registros con id BETWEEN 9000 AND 9009
-- =========================================

-- 1) INSERT de lote vía vista
PRINT '--- 1) INSERT de lote vía vista (registros de prueba id 9000..9004) ---';
INSERT INTO dbo.vw_partidos_basicos
    (id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada)
-- Evitar error si ya existen: sólo insertar los ids que no existan
SELECT v.id, v.liga_id, v.fecha_utc, v.equipo_local, v.equipo_visitante, v.estado, v.temporada
FROM (VALUES
    (9000, 1, CAST(DATEADD(DAY, 30, GETUTCDATE()) AS DATETIME2(0)),  1,  8, 0, YEAR(GETUTCDATE())),
    (9001, 1, CAST(DATEADD(DAY, 31, GETUTCDATE()) AS DATETIME2(0)), 11, 12, 0, YEAR(GETUTCDATE())),
    (9002, 3, CAST(DATEADD(DAY, 15, GETUTCDATE()) AS DATETIME2(0)),  5,  4, 0, YEAR(GETUTCDATE())),
    (9003, 4, CAST(DATEADD(DAY, 45, GETUTCDATE()) AS DATETIME2(0)),  6,  7, 0, YEAR(GETUTCDATE())),
    (9004, 5, CAST(DATEADD(DAY, 60, GETUTCDATE()) AS DATETIME2(0)),  9, 10, 0, YEAR(GETUTCDATE()))
) AS v(id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada)
WHERE NOT EXISTS (SELECT 1 FROM dbo.partidos p WHERE p.id = v.id);
GO

-- Control: ver registros en la vista y en la tabla base (sólo los de prueba)
PRINT 'SELECT desde la vista (registros de prueba)';
SELECT * 
FROM dbo.vw_partidos_basicos 
WHERE id BETWEEN 9000 AND 9009
ORDER BY id;

PRINT 'SELECT desde la tabla base (registros de prueba)';
SELECT id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada
FROM dbo.partidos
WHERE id BETWEEN 9000 AND 9009
ORDER BY id;
GO

-- 2) UPDATE vía vista (ej.: cambiar estado a 1 (vivo) para un par de pruebas)
PRINT '--- 2) UPDATE vía vista (marcar como en vivo estado = 1) ---';
UPDATE dbo.vw_partidos_basicos
SET estado = 1
WHERE id IN (9000, 9002) AND estado = 0;
GO

-- Control: verificar UPDATE
SELECT id, estado 
FROM dbo.vw_partidos_basicos 
WHERE id IN (9000, 9002);

SELECT id, estado 
FROM dbo.partidos 
WHERE id IN (9000, 9002);
GO

-- 3) DELETE de registros de prueba vía vista
PRINT '--- 3) DELETE vía vista (borrar registros de prueba id 9000..9004) ---';
DELETE FROM dbo.vw_partidos_basicos
WHERE id BETWEEN 9000 AND 9004;
GO

-- Control final: deben desaparecer de la vista y la tabla
SELECT COUNT(*) AS registros_prueba_en_vista
FROM dbo.vw_partidos_basicos
WHERE id BETWEEN 9000 AND 9009;

SELECT COUNT(*) AS registros_prueba_en_tabla
FROM dbo.partidos
WHERE id BETWEEN 9000 AND 9009;
GO

-- Nota:
-- La vista es actualizable porque:
--   - se basa en una sola tabla,
--   - no tiene DISTINCT, GROUP BY ni agregados,
--   - no tiene expresiones no deterministas.
