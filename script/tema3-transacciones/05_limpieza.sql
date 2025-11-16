-- ================================
-- 05 - LIMPIEZA DE DATOS DE PRUEBA
-- ================================

PRINT 'Eliminando movimientos de prueba...';

DELETE FROM Movimientos
WHERE IdMovimiento IN (1001, 2001, 2002, 3001);

PRINT 'Registros eliminados correctamente';
