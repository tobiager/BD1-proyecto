-- =========================================================
-- Tribuneros - Script de Limpieza
-- Tema 3: Eliminar procedimientos y datos de prueba
-- =========================================================

USE tribuneros_bdi;
GO

PRINT '===============================================';
PRINT 'LIMPIEZA DE PROCEDIMIENTOS Y DATOS DE PRUEBA';
PRINT '===============================================';
PRINT '';

-- =====================================================================
-- ELIMINAR PROCEDIMIENTOS ALMACENADOS
-- =====================================================================

PRINT 'Eliminando procedimientos almacenados...';

IF OBJECT_ID('dbo.sp_Registrar_Usuario_Completo') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.sp_Registrar_Usuario_Completo;
  PRINT '✓ sp_Registrar_Usuario_Completo eliminado';
END

IF OBJECT_ID('dbo.sp_Calificar_y_Opinar') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.sp_Calificar_y_Opinar;
  PRINT '✓ sp_Calificar_y_Opinar eliminado';
END

IF OBJECT_ID('dbo.sp_Seguir_Equipo_Con_Recordatorios') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.sp_Seguir_Equipo_Con_Recordatorios;
  PRINT '✓ sp_Seguir_Equipo_Con_Recordatorios eliminado';
END

IF OBJECT_ID('dbo.sp_Registrar_Actividad_Usuario_Completa') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.sp_Registrar_Actividad_Usuario_Completa;
  PRINT '✓ sp_Registrar_Actividad_Usuario_Completa eliminado';
END

PRINT '';

-- =====================================================================
-- ELIMINAR DATOS DE PRUEBA
-- =====================================================================

PRINT 'Eliminando datos de prueba...';

BEGIN TRY
  BEGIN TRANSACTION LimpiezaDatos;
  
  -- Eliminar recordatorios de prueba
  DELETE FROM dbo.recordatorios
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Recordatorios de prueba eliminados';
  
  -- Eliminar seguimientos de prueba
  DELETE FROM dbo.seguimiento_equipos
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Seguimientos de equipos de prueba eliminados';
  
  -- Eliminar favoritos de prueba
  DELETE FROM dbo.favoritos
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Favoritos de prueba eliminados';
  
  -- Eliminar visualizaciones de prueba
  DELETE FROM dbo.visualizaciones
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Visualizaciones de prueba eliminadas';
  
  -- Eliminar opiniones de prueba
  DELETE FROM dbo.opiniones
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Opiniones de prueba eliminadas';
  
  -- Eliminar calificaciones de prueba
  DELETE FROM dbo.calificaciones
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Calificaciones de prueba eliminadas';
  
  -- Eliminar partidos de prueba (creados hoy)
  DELETE FROM dbo.partidos
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Partidos de prueba eliminados';
  
  -- Eliminar perfiles de usuarios de prueba
  DELETE FROM dbo.perfiles
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Perfiles de prueba eliminados';
  
  -- Eliminar usuarios de prueba
  DELETE FROM dbo.usuarios
  WHERE creado_en >= CAST(GETDATE() AS DATE);
  PRINT '✓ Usuarios de prueba eliminados';
  
  COMMIT TRANSACTION LimpiezaDatos;
  
  PRINT '';
  PRINT '===============================================';
  PRINT 'LIMPIEZA COMPLETADA EXITOSAMENTE';
  PRINT '===============================================';
  
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION LimpiezaDatos;
  
  PRINT '';
  PRINT 'ERROR durante la limpieza:';
  PRINT ERROR_MESSAGE();
END CATCH
GO

-- =====================================================================
-- VERIFICAR LIMPIEZA
-- =====================================================================

PRINT '';
PRINT 'Verificación final:';
PRINT '';

SELECT 'Usuarios creados hoy' AS Tabla, COUNT(*) AS Cantidad
FROM dbo.usuarios WHERE creado_en >= CAST(GETDATE() AS DATE)
UNION ALL
SELECT 'Perfiles creados hoy', COUNT(*)
FROM dbo.perfiles WHERE creado_en >= CAST(GETDATE() AS DATE)
UNION ALL
SELECT 'Partidos creados hoy', COUNT(*)
FROM dbo.partidos WHERE creado_en >= CAST(GETDATE() AS DATE)
UNION ALL
SELECT 'Calificaciones creadas hoy', COUNT(*)
FROM dbo.calificaciones WHERE creado_en >= CAST(GETDATE() AS DATE)
UNION ALL
SELECT 'Opiniones creadas hoy', COUNT(*)
FROM dbo.opiniones WHERE creado_en >= CAST(GETDATE() AS DATE);

PRINT '';
PRINT 'Si todos los contadores muestran 0, la limpieza fue exitosa.';
GO
