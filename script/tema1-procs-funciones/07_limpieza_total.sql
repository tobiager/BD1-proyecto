-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 07_limpieza_total.sql
--
-- Script para eliminar todos los objetos y datos de prueba
-- creados en este tema. Devuelve la base de datos a su
-- estado anterior.
-- =================================================================
USE tribuneros_bdi;
GO

PRINT '-----------------------------------------------------'
PRINT '--- INICIO: Limpieza de datos y objetos del Tema 1 ---'
PRINT '-----------------------------------------------------'
GO

PRINT '--- 1. Eliminando datos de prueba de la tabla [opiniones] ---';

-- Eliminar datos insertados por 03_datos_insert_directo.sql
DELETE FROM dbo.opiniones
WHERE id IN (101, 102, 103);

-- Eliminar datos insertados por 04_datos_insert_via_sp.sql
DELETE FROM dbo.opiniones
WHERE partido_id = 5 AND usuario_id IN (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444'
);

-- Eliminar datos de prueba de 06_pruebas_procedimientos.sql (por si falló la transacción)
DELETE FROM dbo.opiniones
WHERE partido_id = 2 AND usuario_id = '33333333-3333-3333-3333-333333333333';

PRINT '-> Datos de prueba eliminados.';
GO

PRINT '--- 2. Eliminando Procedimientos Almacenados ---';
DROP PROCEDURE IF EXISTS dbo.sp_Insertar_Opinion;
DROP PROCEDURE IF EXISTS dbo.sp_Modificar_Opinion;
DROP PROCEDURE IF EXISTS dbo.sp_Borrar_Opinion;
PRINT '-> Procedimientos eliminados.';
GO

PRINT '--- 3. Eliminando Funciones ---';
DROP FUNCTION IF EXISTS dbo.fn_ObtenerNombreUsuario;
DROP FUNCTION IF EXISTS dbo.fn_CalcularPuntajePromedioPartido;
DROP FUNCTION IF EXISTS dbo.fn_FormatearResultadoPartido;
PRINT '-> Funciones eliminadas.';
GO

PRINT ' '
PRINT '-----------------------------------------------------'
PRINT '--- FIN: Limpieza completada. ---'
PRINT '-----------------------------------------------------'
GO
