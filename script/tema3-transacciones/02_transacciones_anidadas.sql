-- ================================
-- 02 - PRUEBAS DE TRANSACCIONES ANIDADAS
-- ================================

BEGIN TRY
    BEGIN TRAN trans_principal;
        PRINT 'Transacción principal iniciada';

        -- Llamada al procedimiento de inserción (éxito)
        EXEC sp_InsertarMovimiento @IdMovimiento = 1001, @Descripcion = 'Movimiento principal OK';

        BEGIN TRAN trans_secundaria;
            PRINT 'Transacción secundaria iniciada';

            -- Llamada al procedimiento de inserción secundaria (fallará porque la PK existe o por validación)
            EXEC sp_InsertarMovimiento @IdMovimiento = 1001, @Descripcion = 'Movimiento duplicado';

        COMMIT TRAN trans_secundaria;
        PRINT 'Transacción secundaria confirmada';

    COMMIT TRAN trans_principal;
    PRINT 'Transacción principal confirmada';

END TRY
BEGIN CATCH
    PRINT 'Error detectado: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
END CATCH;
