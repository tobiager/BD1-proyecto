-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 06_pruebas_procedimientos.sql 
-- Prueba CRUD completa usando los procedimientos adaptados al nuevo esquema.
-- Importante:
--  - Ejecutar después de carga_inicial.sql (crea usuarios, partidos, equipos, etc).
-- =================================================================
USE tribuneros_bdi;
GO

SET NOCOUNT ON;
PRINT '-----------------------------------------------------';
PRINT '--- INICIO: Pruebas de Procedimientos CRUD ---';
PRINT '-----------------------------------------------------';

-- Variables de prueba (usar usuarios/partidos creados en carga_inicial.sql)
DECLARE @opinion_id_prueba INT = NULL;
DECLARE @usuario_prueba INT = 2; -- usuario 'ana.ferro' según carga_inicial.sql
DECLARE @partido_prueba INT = 2; -- partido de ejemplo
DECLARE @obtenida_id INT = NULL;
DECLARE @id_a_borrar INT = NULL;

-- Usamos una única transacción para las 3 operaciones y la revertimos al final
BEGIN TRAN;
BEGIN TRY
    -------------------------------------------------------------
    -- 1) INSERTAR una nueva opinión
    -------------------------------------------------------------
    PRINT '--- 1. Intentando INSERTAR una nueva opinión ---';

    EXEC dbo.sp_Insertar_Opinion
        @partido_id = @partido_prueba,
        @usuario_id = @usuario_prueba,
        @titulo = N'Derby de Manchester (test)',
        @cuerpo = N'Un partido muy táctico, el City dominó la posesión.',
        @publica = 1,
        @tiene_spoilers = 0,
        @opinion_id = @opinion_id_prueba OUTPUT;

    PRINT '-> Opinión insertada con éxito. Nuevo ID: ' + CAST(@opinion_id_prueba AS VARCHAR(20));

    -- Mostrar la fila recién insertada
    SELECT * FROM dbo.opiniones WHERE id = @opinion_id_prueba;

    -------------------------------------------------------------
    -- 2) MODIFICAR la opinión recién creada
    -------------------------------------------------------------
    PRINT '--- 2. Intentando MODIFICAR la opinión recién creada ---';

    -- Obtenemos el id de la opinión insertada (por seguridad, si no vino por OUTPUT)
    IF @opinion_id_prueba IS NOT NULL
        SET @obtenida_id = @opinion_id_prueba;
    ELSE
        SELECT TOP 1 @obtenida_id = id FROM dbo.opiniones WHERE usuario_id = @usuario_prueba AND partido_id = @partido_prueba ORDER BY creado_en DESC;

    IF @obtenida_id IS NOT NULL
    BEGIN
        EXEC dbo.sp_Modificar_Opinion
            @opinion_id = @obtenida_id,
            @usuario_id = @usuario_prueba,
            @titulo = N'Derby de Manchester (Editado)',
            @cuerpo = N'Edición de prueba: mejor detalle del partido.',
            @publica = 1,
            @tiene_spoilers = 1;

        PRINT '-> Opinión modificada con éxito. ID: ' + CAST(@obtenida_id AS VARCHAR(20));
        SELECT * FROM dbo.opiniones WHERE id = @obtenida_id;
    END
    ELSE
    BEGIN
        PRINT '-> No se encontró la opinión para modificar.';
    END

    -------------------------------------------------------------
    -- 3) BORRAR la opinión
    -------------------------------------------------------------
    PRINT '--- 3. Intentando BORRAR la opinión ---';

    -- Determinamos el id a borrar (la misma creada/modificada)
    IF @obtenida_id IS NOT NULL
        SET @id_a_borrar = @obtenida_id;
    ELSE
        SELECT TOP 1 @id_a_borrar = id FROM dbo.opiniones WHERE usuario_id = @usuario_prueba AND partido_id = @partido_prueba ORDER BY creado_en DESC;

    IF @id_a_borrar IS NOT NULL
    BEGIN
        EXEC dbo.sp_Borrar_Opinion @opinion_id = @id_a_borrar, @usuario_id = @usuario_prueba;
        PRINT '-> Procedimiento de borrado ejecutado. ID borrado: ' + CAST(@id_a_borrar AS VARCHAR(20));

        IF NOT EXISTS (SELECT 1 FROM dbo.opiniones WHERE id = @id_a_borrar)
            PRINT '-> Verificación: La opinión fue borrada correctamente.';
        ELSE
            PRINT '-> Verificación: ERROR, la opinión todavía existe.';
    END
    ELSE
    BEGIN
        PRINT '-> No se encontró la opinión para borrar.';
    END

    -- Terminamos bien: revertimos para no dejar datos de prueba
    PRINT '--- Revirtiendo transacción de prueba (ROLLBACK) ---';
    ROLLBACK TRAN;

    PRINT '--- FIN: Pruebas completadas (cambios revertidos). ---';
END TRY
BEGIN CATCH
    DECLARE @err_msg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @err_sev INT = ERROR_SEVERITY();
    DECLARE @err_state INT = ERROR_STATE();

    PRINT '-> ERROR detectado durante las pruebas: ' + ISNULL(@err_msg, '(sin mensaje)');
    -- Si hay una transacción abierta, revertimos
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRAN;
        PRINT '-> Transacción revertida por error.';
    END

    -- Re-lanzamos el error para visibilidad si se desea (opcional)
    -- THROW;
END CATCH;

GO