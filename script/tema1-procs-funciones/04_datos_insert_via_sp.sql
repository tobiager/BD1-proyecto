-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 04_datos_insert_via_sp.sql 
-- Usa usuarios creados por carga_inicial.sql (IDs 1..10).
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
-- Usamos usuarios existentes: 6 (sofia), 9 (diego), 10 (elena)
EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = 6,  @titulo = N'Derby visto por un neutral', @cuerpo = N'El Inter fue una máquina. Impresionante.', @publica = 1, @tiene_spoilers = 1, @opinion_id = @new_id OUTPUT;
PRINT ' -> Nuevo ID: ' + CAST(@new_id AS VARCHAR(20));

EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = 9,  @titulo = N'Fútbol italiano', @cuerpo = N'Qué partidazo, la Serie A está viva.', @publica = 1, @tiene_spoilers = 0, @opinion_id = @new_id OUTPUT;
PRINT ' -> Nuevo ID: ' + CAST(@new_id AS VARCHAR(20));

EXEC dbo.sp_Insertar_Opinion @partido_id = 5, @usuario_id = 10, @titulo = N'Goleada inesperada', @cuerpo = N'No esperaba este resultado en un clásico tan parejo.', @publica = 1, @tiene_spoilers = 1, @opinion_id = @new_id OUTPUT;
PRINT ' -> Nuevo ID: ' + CAST(@new_id AS VARCHAR(20));

COMMIT TRAN;

PRINT '--- FIN: Inserción de opiniones vía SP ---';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO