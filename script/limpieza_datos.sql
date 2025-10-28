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

PRINT 'Iniciando limpieza de datos...';

-- La eliminación se hace en orden inverso a la creación para respetar las FK.
DELETE FROM dbo.recordatorios;
DELETE FROM dbo.partidos_destacados;
DELETE FROM dbo.seguimiento_usuarios;  
DELETE FROM dbo.seguimiento_ligas;     
DELETE FROM dbo.seguimiento_equipos;   
DELETE FROM dbo.visualizaciones;
DELETE FROM dbo.favoritos;
DELETE FROM dbo.opiniones;
DELETE FROM dbo.calificaciones;
DELETE FROM dbo.partidos;
DELETE FROM dbo.equipos;
DELETE FROM dbo.ligas;
DELETE FROM dbo.perfiles;
DELETE FROM dbo.usuarios;

PRINT 'Todas las tablas han sido limpiadas.';
GO