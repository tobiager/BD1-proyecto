-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 06_pruebas_procedimientos.sql
--
-- Script para probar el ciclo de vida CRUD de una opinión
-- utilizando los procedimientos almacenados.
-- =================================================================
USE tribuneros_bdi;
GO

PRINT '-----------------------------------------------------'
PRINT '--- INICIO: Pruebas de Procedimientos CRUD ---'
PRINT '-----------------------------------------------------'
GO

-- Declaramos variables para la prueba
DECLARE @opinion_id_prueba INT;
DECLARE @usuario_prueba CHAR(36) = '33333333-3333-3333-3333-333333333333'; -- Usuario 'ana.ferro'
DECLARE @partido_prueba INT = 2; -- Partido: Man City vs Man United

-- Usaremos una transacción para poder revertir los cambios al final si queremos
BEGIN TRAN;

-- 1. INSERTAR una nueva opinión
PRINT '--- 1. Intentando INSERTAR una nueva opinión para el usuario ''ana.ferro'' ---';
BEGIN TRY
    EXEC dbo.sp_Insertar_Opinion
        @partido_id = @partido_prueba,
        @usuario_id = @usuario_prueba,
        @titulo = 'Derby de Manchester',
        @cuerpo = 'Un partido muy táctico, el City dominó la posesión.',
        @publica = 1,
        @tiene_spoilers = 0,
        @opinion_id = @opinion_id_prueba OUTPUT;

    PRINT '-> Opinión insertada con éxito. Nuevo ID: ' + CAST(@opinion_id_prueba AS VARCHAR);

    -- Verificamos que se haya insertado
    SELECT * FROM dbo.opiniones WHERE id = @opinion_id_prueba;
END TRY
BEGIN CATCH
    PRINT '-> ERROR al insertar: ' + ERROR_MESSAGE();
END CATCH
GO

-- 2. MODIFICAR la opinión recién creada
PRINT '--- 2. Intentando MODIFICAR la opinión recién creada ---';
DECLARE @opinion_id_prueba INT = (SELECT id FROM dbo.opiniones WHERE usuario_id = '33333333-3333-3333-3333-333333333333' AND partido_id = 2);
DECLARE @usuario_prueba CHAR(36) = '33333333-3333-3333-3333-333333333333';

BEGIN TRY
    EXEC dbo.sp_Modificar_Opinion
        @opinion_id = @opinion_id_prueba,
        @usuario_id = @usuario_prueba,
        @titulo = 'Derby de Manchester (Editado)',
        @cuerpo = 'Un partido muy táctico, el City dominó la posesión. El resultado fue justo.',
        @publica = 1,
        @tiene_spoilers = 1;

    PRINT '-> Opinión modificada con éxito.';
    -- Verificamos la modificación
    SELECT * FROM dbo.opiniones WHERE id = @opinion_id_prueba;
END TRY
BEGIN CATCH
    PRINT '-> ERROR al modificar: ' + ERROR_MESSAGE();
END CATCH
GO

-- 3. BORRAR la opinión
PRINT '--- 3. Intentando BORRAR la opinión ---';
DECLARE @opinion_id_prueba INT = (SELECT id FROM dbo.opiniones WHERE usuario_id = '33333333-3333-3333-3333-333333333333' AND partido_id = 2);
DECLARE @usuario_prueba CHAR(36) = '33333333-3333-3333-3333-333333333333';

EXEC dbo.sp_Borrar_Opinion @opinion_id = @opinion_id_prueba, @usuario_id = @usuario_prueba;
PRINT '-> Procedimiento de borrado ejecutado.';

-- Verificamos que ya no exista
IF NOT EXISTS (SELECT 1 FROM dbo.opiniones WHERE id = @opinion_id_prueba)
    PRINT '-> Verificación: La opinión fue borrada correctamente.';
ELSE
    PRINT '-> Verificación: ERROR, la opinión todavía existe.';

-- Revertimos la transacción para no dejar datos de prueba en la BD
ROLLBACK TRAN;
PRINT '--- Cambios revertidos. La base de datos está en su estado original. ---';
GO