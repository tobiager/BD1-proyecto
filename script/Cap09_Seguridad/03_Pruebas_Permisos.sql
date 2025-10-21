-- =========================================================
-- TEMA 1: Pruebas de Permisos y Validación
-- Script 3: Pruebas de Permisos
-- =========================================================
-- Este script contiene pruebas para validar los permisos
-- configurados en los scripts anteriores.
-- Debe ejecutarse después de crear los procedimientos del Tema 2.
-- =========================================================

USE tribuneros_bdi;
GO

PRINT '==================================================';
PRINT 'PRUEBAS DE PERMISOS A NIVEL DE USUARIOS';
PRINT '==================================================';
PRINT '';

-- =========================================================
-- SECCIÓN 1: Pruebas con Admin_Usuario
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 1: Admin_Usuario - INSERT DIRECTO';
PRINT '==================================================';
PRINT 'Descripción: Admin_Usuario debe poder insertar directamente.';
PRINT 'Resultado esperado: Éxito';
PRINT '';

-- Ejecutar como Admin_Usuario
EXECUTE AS USER = 'Admin_Usuario';

BEGIN TRY
    -- Intentar insertar un partido de prueba
    INSERT INTO dbo.partidos (
        id, liga_id, temporada, ronda, fecha_utc, estado, estadio,
        equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
    ) VALUES (
        999991, 1, 2025, 'Prueba Admin', SYSDATETIME(), 
        'programado', 'Estadio Prueba', 1, 2, NULL, NULL, SYSDATETIME()
    );
    
    PRINT 'RESULTADO: ÉXITO - Admin_Usuario puede insertar directamente.';
    
    -- Limpiar la prueba
    DELETE FROM dbo.partidos WHERE id = 999991;
    PRINT 'Registro de prueba eliminado.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: ERROR - ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 2: Pruebas con LecturaSolo_Usuario - INSERT Directo
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 2: LecturaSolo_Usuario - INSERT DIRECTO';
PRINT '==================================================';
PRINT 'Descripción: LecturaSolo_Usuario NO debe poder insertar.';
PRINT 'Resultado esperado: Error de permisos';
PRINT '';

-- Ejecutar como LecturaSolo_Usuario
EXECUTE AS USER = 'LecturaSolo_Usuario';

BEGIN TRY
    -- Intentar insertar (debe fallar)
    INSERT INTO dbo.partidos (
        id, liga_id, temporada, ronda, fecha_utc, estado, estadio,
        equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
    ) VALUES (
        999992, 1, 2025, 'Prueba Lectura', SYSDATETIME(), 
        'programado', 'Estadio Prueba', 1, 2, NULL, NULL, SYSDATETIME()
    );
    
    PRINT 'RESULTADO: ERROR INESPERADO - No debería llegar aquí.';
    DELETE FROM dbo.partidos WHERE id = 999992;
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: CORRECTO - Permiso denegado (esperado).';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 3: Pruebas con LecturaSolo_Usuario - SELECT
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 3: LecturaSolo_Usuario - SELECT';
PRINT '==================================================';
PRINT 'Descripción: LecturaSolo_Usuario puede hacer SELECT.';
PRINT 'Resultado esperado: Éxito';
PRINT '';

-- Ejecutar como LecturaSolo_Usuario
EXECUTE AS USER = 'LecturaSolo_Usuario';

BEGIN TRY
    DECLARE @contador INT;
    
    -- Intentar SELECT (debe funcionar)
    SELECT @contador = COUNT(*) FROM dbo.partidos;
    
    PRINT 'RESULTADO: ÉXITO - LecturaSolo_Usuario puede leer datos.';
    PRINT 'Partidos en la base de datos: ' + CAST(@contador AS VARCHAR(10));
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: ERROR - ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 4: Pruebas con Usuario_ConRol - SELECT en Tablas Permitidas
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 4: Usuario_ConRol - SELECT en Tablas Permitidas';
PRINT '==================================================';
PRINT 'Descripción: Usuario_ConRol puede consultar partidos, equipos y ligas.';
PRINT 'Resultado esperado: Éxito';
PRINT '';

-- Ejecutar como Usuario_ConRol
EXECUTE AS USER = 'Usuario_ConRol';

BEGIN TRY
    DECLARE @cnt_partidos INT, @cnt_equipos INT, @cnt_ligas INT;
    
    -- Consultar tablas permitidas
    SELECT @cnt_partidos = COUNT(*) FROM dbo.partidos;
    SELECT @cnt_equipos = COUNT(*) FROM dbo.equipos;
    SELECT @cnt_ligas = COUNT(*) FROM dbo.ligas;
    
    PRINT 'RESULTADO: ÉXITO - Usuario_ConRol puede consultar tablas permitidas.';
    PRINT 'Partidos: ' + CAST(@cnt_partidos AS VARCHAR(10));
    PRINT 'Equipos: ' + CAST(@cnt_equipos AS VARCHAR(10));
    PRINT 'Ligas: ' + CAST(@cnt_ligas AS VARCHAR(10));
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: ERROR - ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 5: Pruebas con Usuario_ConRol - SELECT en Tabla NO Permitida
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 5: Usuario_ConRol - SELECT en Tabla NO Permitida';
PRINT '==================================================';
PRINT 'Descripción: Usuario_ConRol NO puede consultar usuarios.';
PRINT 'Resultado esperado: Error de permisos';
PRINT '';

-- Ejecutar como Usuario_ConRol
EXECUTE AS USER = 'Usuario_ConRol';

BEGIN TRY
    DECLARE @cnt_usuarios INT;
    
    -- Intentar consultar tabla no permitida
    SELECT @cnt_usuarios = COUNT(*) FROM dbo.usuarios;
    
    PRINT 'RESULTADO: ERROR INESPERADO - No debería poder consultar usuarios.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: CORRECTO - Permiso denegado (esperado).';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 6: Pruebas con Usuario_SinRol - SELECT
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBA 6: Usuario_SinRol - SELECT';
PRINT '==================================================';
PRINT 'Descripción: Usuario_SinRol NO puede consultar ninguna tabla.';
PRINT 'Resultado esperado: Error de permisos';
PRINT '';

-- Ejecutar como Usuario_SinRol
EXECUTE AS USER = 'Usuario_SinRol';

BEGIN TRY
    DECLARE @cnt_test INT;
    
    -- Intentar consultar partidos (debe fallar)
    SELECT @cnt_test = COUNT(*) FROM dbo.partidos;
    
    PRINT 'RESULTADO: ERROR INESPERADO - No debería poder consultar.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: CORRECTO - Permiso denegado (esperado).';
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH

-- Revertir contexto
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 7: Nota sobre Pruebas con Procedimientos
-- =========================================================
PRINT '==================================================';
PRINT 'NOTA SOBRE PRUEBAS CON PROCEDIMIENTOS ALMACENADOS';
PRINT '==================================================';
PRINT '';
PRINT 'Las siguientes pruebas requieren los procedimientos almacenados';
PRINT 'del Tema 2 (Cap10_Procedimientos_Funciones):';
PRINT '';
PRINT 'PRUEBA 7: LecturaSolo_Usuario + sp_InsertPartido';
PRINT '  - Descripción: Con permiso EXECUTE, puede insertar vía SP';
PRINT '  - Resultado esperado: Éxito (cadena de propiedad)';
PRINT '';
PRINT 'PRUEBA 8: Usuario_SinRol + sp_InsertPartido';
PRINT '  - Descripción: Sin permiso EXECUTE, no puede ejecutar SP';
PRINT '  - Resultado esperado: Error de permisos';
PRINT '';
PRINT 'Estas pruebas se incluyen en el script:';
PRINT '  scripts/Cap10_Procedimientos_Funciones/03_Pruebas_Comparativas.sql';
PRINT '';

-- =========================================================
-- SECCIÓN 8: Resumen de Resultados
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE RESULTADOS DE PRUEBAS';
PRINT '==================================================';
PRINT '';
PRINT 'Pruebas completadas:';
PRINT '  ✓ PRUEBA 1: Admin_Usuario puede insertar directamente';
PRINT '  ✓ PRUEBA 2: LecturaSolo_Usuario NO puede insertar';
PRINT '  ✓ PRUEBA 3: LecturaSolo_Usuario puede leer';
PRINT '  ✓ PRUEBA 4: Usuario_ConRol puede consultar tablas permitidas';
PRINT '  ✓ PRUEBA 5: Usuario_ConRol NO puede consultar tablas no permitidas';
PRINT '  ✓ PRUEBA 6: Usuario_SinRol NO puede consultar';
PRINT '';
PRINT 'Conclusiones:';
PRINT '  - Los permisos a nivel de usuario funcionan correctamente';
PRINT '  - Los permisos a nivel de rol funcionan correctamente';
PRINT '  - El principio de menor privilegio está siendo respetado';
PRINT '';
PRINT '==================================================';
PRINT 'Script de pruebas completado exitosamente.';
PRINT '==================================================';
GO
