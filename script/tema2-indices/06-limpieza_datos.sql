-- =========================================================
-- Tribuneros - Limpieza completa de datos (DML)
-- =========================================================
-- Propósito: Este script elimina todos los registros de
--            las tablas transaccionales para permitir
--            una nueva carga de datos desde cero.
-- =========================================================

SET XACT_ABORT ON;
GO

USE tribuneros_bdi;
GO

PRINT N'Iniciando limpieza de datos...';

-- La eliminación se hace en orden inverso a la creación para respetar las FK.  
DELETE FROM dbo.partidos;
DELETE FROM dbo.equipos;
DELETE FROM dbo.ligas;

PRINT N'Todas las tablas han sido limpiadas.';
GO