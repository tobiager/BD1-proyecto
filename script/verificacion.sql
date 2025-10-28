-- =========================================================
-- Tribuneros - Verificación de datos y lógica (DML & DCL)
-- =========================================================
-- Propósito: Este script contiene consultas para verificar
--            la integridad de los datos cargados y probar
--            la lógica de negocio (como la autenticación).
-- =========================================================

-- Usuarios cargados
SELECT * FROM usuarios;
SELECT * FROM perfiles;

-- Catálogos
SELECT * FROM ligas;
SELECT * FROM equipos;

-- Partido cargado
SELECT * FROM partidos;

-- Interacciones
SELECT * FROM calificaciones;
SELECT * FROM opiniones;
SELECT * FROM favoritos;
SELECT * FROM visualizaciones;

-- Social
SELECT * FROM seguimiento_equipos;
SELECT * FROM seguimiento_ligas;
SELECT * FROM seguimiento_usuarios;
SELECT * FROM recordatorios;
SELECT * FROM partidos_destacados;

GO

PRINT '=================================================';
PRINT '======= Verificación de Autenticación =========';
PRINT '=================================================';

-- Caso 1: Login exitoso con contraseña correcta
PRINT '-> Test 1: Login para tobiager@example.com con contraseña correcta (RiverPlate2018!). Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'RiverPlate2018!';
GO

-- Caso 2: Login fallido con contraseña incorrecta
PRINT '-> Test 2: Login para tobiager@example.com con contraseña incorrecta. Esperado: ok=0.';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'ContrasenaFalsa!';
GO

-- Caso 3: Login exitoso para otro usuario
PRINT '-> Test 3: Login para ana.ferro@example.com con contraseña correcta (VelezSarsfield!). Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = 'ana.ferro@example.com', @password = N'VelezSarsfield!';
GO

-- Caso 4: Cambio de contraseña y nuevo login
PRINT '-> Test 4: Cambiando contraseña para tobiager@example.com a "NewRiverPass!"...';
EXEC dbo.sp_usuario_set_password_simple @usuario_id = '11111111-1111-1111-1111-111111111111', @password = N'NewRiverPass!';
PRINT '-> Test 4.1: Re-intentando login con la nueva contraseña. Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'NewRiverPass!';
PRINT '-> Test 4.2: Intentando login con la contraseña antigua. Esperado: ok=0.';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'RiverPlate2018!';
GO
