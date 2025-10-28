-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 03_datos_insert_directo.sql
--
-- Lote de inserciones directas en la tabla de opiniones para
-- medir rendimiento.
-- =================================================================
USE tribuneros_bdi;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '--- INICIO: Inserción directa de opiniones ---';

BEGIN TRAN;

-- Insertar 3 opiniones nuevas para el partido 6 (Clásico de Avellaneda)
INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en) VALUES
(101, 6, '11111111-1111-1111-1111-111111111111', 'Visto desde afuera', 'Un clásico con mucha tensión. Independiente fue más efectivo.', 1, 1, SYSDATETIME()),
(102, 6, '22222222-2222-2222-2222-222222222222', 'Clásico es clásico', 'Partidos que se juegan con el corazón.', 1, 0, SYSDATETIME()),
(103, 6, '44444444-4444-4444-4444-444444444444', 'Avellaneda en rojo', 'Gran victoria del Rojo, merecida.', 1, 1, SYSDATETIME());

COMMIT TRAN;

PRINT '--- FIN: Inserción directa de opiniones ---';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO