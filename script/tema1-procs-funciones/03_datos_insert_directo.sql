-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 03_datos_insert_directo.sql 
-- Usa los usuarios creados por carga_inicial.sql (IDs 1..10).
-- =================================================================
USE tribuneros_bdi;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '--- INICIO: Inserción directa de opiniones ---';

BEGIN TRAN;

-- Insertar 3 opiniones nuevas para el partido 6 (Clásico de Avellaneda)
-- Usamos usuario_id que existen en carga_inicial: 8 (Independiente fan), 11/44 no existen en carga_inicial
-- Hecho: usar IDs 8,11 no válidos; aquí usamos 8,9,11? --- Ajustado para usar usuarios existentes 8,9,6 (ejemplo).
-- Elegir usuarios existentes: 8,9,6 (puedes cambiar si prefieres otros)
INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en) VALUES
(6, 8, N'Visto desde afuera', N'Un clásico con mucha tensión. Independiente fue más efectivo.', 1, 1, SYSDATETIME()),
(6, 9, N'Clásico es clásico', N'Partidos que se juegan con el corazón.', 1, 0, SYSDATETIME()),
(6, 6, N'Avellaneda en rojo', N'Gran victoria del Rojo, merecida.', 1, 1, SYSDATETIME());

COMMIT TRAN;

PRINT '--- FIN: Inserción directa de opiniones ---';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO