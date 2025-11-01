-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 04_datos_insert_via_sp.sql
--
-- Lote de inserciones invocando el SP para medir rendimiento.
-- =================================================================
USE tribuneros_bdi;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '--- INICIO: Inserción de opiniones vía SP ---';

BEGIN TRAN;

DECLARE @new_id INT;

-- Insertar 3 opiniones nuevas para el partido 5 (Derby de Milan)
EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = '11111111-1111-1111-1111-111111111111', @titulo = 'Derby visto por un neutral', @cuerpo = 'El Inter fue una máquina. Impresionante.', @publica = 1, @tiene_spoilers = 1, @opinion_id = @new_id OUTPUT;

EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = '22222222-2222-2222-2222-222222222222', @titulo = 'Fútbol italiano', @cuerpo = 'Qué partidazo, la Serie A está viva.', @publica = 1, @tiene_spoilers = 0, @opinion_id = @new_id OUTPUT;

EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = '44444444-4444-4444-4444-444444444444', @titulo = 'Goleada inesperada', @cuerpo = 'No esperaba este resultado en un clásico tan parejo.', @publica = 1, @tiene_spoilers = 1, @opinion_id = @new_id OUTPUT;

COMMIT TRAN;

PRINT '--- FIN: Inserción de opiniones vía SP ---';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO