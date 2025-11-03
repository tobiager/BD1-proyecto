-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 07_limpieza_total.sql (ELIMINA SOLO LO CREADO POR LOS SCRIPTS 01..06)
--
-- Este script borra únicamente:
--  - las filas en dbo.opiniones creadas por los scripts 03 y 04 (identificadas por título),
--  - cualquier fila residual creada por pruebas en 06 (identificadas por título/usuario/partido si aplica),
--  - los procedimientos y funciones introducidos en 01 y 02.
-- =================================================================
USE tribuneros_bdi;
GO

SET NOCOUNT ON;
PRINT '--- INICIO: Limpieza específica del Tema 1 (scripts 01..06) ---';

BEGIN TRAN;

-- 1) Eliminar las opiniones creadas por 03_datos_insert_directo.sql y 04_datos_insert_via_sp.sql
--    (identificadas por los títulos usados en esos scripts).
--    Ajusta la lista si en tu entorno cambiaste los textos.

DELETE FROM dbo.opiniones
WHERE titulo IN (
    N'Visto desde afuera',
    N'Clásico es clásico',
    N'Avellaneda en rojo',
    N'Derby visto por un neutral',
    N'Fútbol italiano',
    N'Goleada inesperada',
    N'Derby de Manchester (test)',        -- posible título usado en pruebas 06 (si no rollback)
    N'Derby de Manchester (Editado)'      -- variante tras edición en 06 (si existe)
);

-- 2) Si las pruebas crearon otras filas con títulos parecidos, limpiamos por combinación
--    usuario/partido usados en los scripts adaptados (solo para asegurarnos de borrar
--    residuos de pruebas, sin tocar la carga inicial).
--    Estos son los pares usados en los scripts adaptados proporcionados:
DELETE FROM dbo.opiniones
WHERE (partido_id = 6 AND usuario_id IN (6,8,9))  -- inserciones directas en 03 (usuarios ejemplo)
   OR (partido_id = 5 AND usuario_id IN (6,9,10)); -- inserciones vía SP en 04 (usuarios ejemplo)

-- 3) Eliminar procedimientos almacenados del Tema 1
IF OBJECT_ID('dbo.sp_Insertar_Opinion', 'P') IS NOT NULL
  DROP PROCEDURE dbo.sp_Insertar_Opinion;

IF OBJECT_ID('dbo.sp_Modificar_Opinion', 'P') IS NOT NULL
  DROP PROCEDURE dbo.sp_Modificar_Opinion;

IF OBJECT_ID('dbo.sp_Borrar_Opinion', 'P') IS NOT NULL
  DROP PROCEDURE dbo.sp_Borrar_Opinion;

-- 4) Eliminar funciones escalares del Tema 1
IF OBJECT_ID('dbo.fn_ObtenerNombreUsuario', 'FN') IS NOT NULL
  DROP FUNCTION dbo.fn_ObtenerNombreUsuario;

IF OBJECT_ID('dbo.fn_CalcularPuntajePromedioPartido', 'FN') IS NOT NULL
  DROP FUNCTION dbo.fn_CalcularPuntajePromedioPartido;

IF OBJECT_ID('dbo.fn_FormatearResultadoPartido', 'FN') IS NOT NULL
  DROP FUNCTION dbo.fn_FormatearResultadoPartido;

COMMIT TRAN;

PRINT '-> Limpieza completada. Se eliminaron los objetos y datos creados por los scripts 01..06 (según los criterios aplicados).';
PRINT '-> Si deseas mayor conservadurismo (ej. eliminar solo por títulos y no por partido/usuario), edita las condiciones DELETE antes de ejecutar.';
GO