-- ================================
-- 04 - PRUEBAS DE ROLLBACK
-- ================================

BEGIN TRY
    BEGIN TRAN;
        PRINT 'Transacción iniciada para prueba de rollback';

        -- Primera inserción OK
        EXEC sp_InsertarMovimiento @IdMovimiento = 3001, @Descripcion = 'Movimiento válido';

        -- Segunda inserción generará error (ID repetido o validación)
        EXEC sp_InsertarMovimiento @IdMovimiento = 3001, @Descripcion = 'Movimiento que provoca rollback';

    COMMIT TRAN;
    PRINT 'Transacción confirmada (esto no debería imprimirse si hay error)';

END TRY
BEGIN CATCH
    PRINT 'Error encontrado: ' + ERROR_MESSAGE();
    PRINT 'Aplicando ROLLBACK...';
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
END CATCH;
