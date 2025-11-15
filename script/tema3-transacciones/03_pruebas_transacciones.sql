-- ================================
-- 03 - PRUEBAS DE TRANSACCIONES NORMALES
-- ================================

BEGIN TRY
    BEGIN TRAN;
        PRINT 'Transacción iniciada';

        -- Inserción válida
        EXEC sp_InsertarMovimiento @IdMovimiento = 2001, @Descripcion = 'Movimiento prueba A';

        -- Inserción válida adicional
        EXEC sp_InsertarMovimiento @IdMovimiento = 2002, @Descripcion = 'Movimiento prueba B';

    COMMIT TRAN;
    PRINT 'Transacción confirmada correctamente';

END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
END CATCH;
