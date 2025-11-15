-- ============================================================
-- SCRIPT 2: PRUEBAS DE TRANSACCIONES ANIDADAS
-- Este archivo crea la tabla de pruebas, el SP para insertar
-- y ejecuta transacciones anidadas para demostrar su manejo.
-- ============================================================

USE tribuneros_bdi;
GO

---------------------------------------------------------------
-- 1) CREACIÓN DE TABLA "Movimientos" (solo para pruebas)
---------------------------------------------------------------
IF OBJECT_ID('dbo.Movimientos') IS NULL
BEGIN
    CREATE TABLE dbo.Movimientos (
        IdMovimiento INT NOT NULL PRIMARY KEY,
        Descripcion  VARCHAR(200) NOT NULL,
        Fecha        DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
    );
    PRINT 'Tabla Movimientos creada.';
END
ELSE
BEGIN
    PRINT 'La tabla Movimientos ya existía.';
END
GO

---------------------------------------------------------------
-- 2) PROCEDIMIENTO sp_InsertarMovimiento
-- Inserta un registro y relanza errores para que la transacción
-- que lo llame pueda manejar el fallo.
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_InsertarMovimiento
    @IdMovimiento INT,
    @Descripcion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Movimientos (IdMovimiento, Descripcion)
        VALUES (@IdMovimiento, @Descripcion);
    END TRY
    BEGIN CATCH
        -- Relanza el error original para permitir rollback externo
        THROW;
    END CATCH
END;
GO

PRINT 'Stored procedure sp_InsertarMovimiento creado/actualizado.';
GO


---------------------------------------------------------------
-- 3) PRUEBAS DE TRANSACCIONES ANIDADAS
-- Este bloque demuestra:
--  - Transacción principal
--  - Transacción secundaria
--  - Error interno (PK duplicada)
--  - Rollback total
---------------------------------------------------------------
PRINT '==============================================';
PRINT 'INICIO DE PRUEBA DE TRANSACCIONES ANIDADAS';
PRINT '==============================================';

BEGIN TRY

    -----------------------------------------------------------
    -- TRANSACCIÓN PRINCIPAL
    -----------------------------------------------------------
    BEGIN TRAN trans_principal;
    PRINT 'Transacción principal iniciada.';

        -------------------------------------------------------
        -- INSERCIÓN CORRECTA
        -------------------------------------------------------
        EXEC sp_InsertarMovimiento 
            @IdMovimiento = 1001,
            @Descripcion = 'Movimiento principal OK';

        -------------------------------------------------------
        -- TRANSACCIÓN SECUNDARIA
        -------------------------------------------------------
        BEGIN TRAN trans_secundaria;
        PRINT 'Transacción secundaria iniciada.';

            ---------------------------------------------------
            -- INSERCIÓN QUE FALLARÁ (PK = 1001 ya existe)
            ---------------------------------------------------
            EXEC sp_InsertarMovimiento 
                @IdMovimiento = 1001,
                @Descripcion = 'Movimiento duplicado';

        COMMIT TRAN trans_secundaria;
        PRINT 'Transacción secundaria confirmada.';

    COMMIT TRAN trans_principal;
    PRINT 'Transacción principal confirmada.';

END TRY
BEGIN CATCH

    PRINT '-----------------------------------------------';
    PRINT '❌ ERROR DETECTADO EN LAS TRANSACCIONES';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
    PRINT '-----------------------------------------------';

    -- Revierte cualquier nivel de transacción activa
    IF @@TRANCOUNT > 0 
    BEGIN
        ROLLBACK TRAN;
        PRINT 'Rollback ejecutado.';
    END
END CATCH;


PRINT '==============================================';
PRINT 'FIN DE PRUEBA DE TRANSACCIONES ANIDADAS';
PRINT '==============================================';
GO
