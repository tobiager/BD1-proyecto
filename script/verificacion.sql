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

PRINT '========== Verificación de Autenticación ==========';

-- 1) Procedimiento para establecer/cambiar contraseña
CREATE OR ALTER PROCEDURE dbo.sp_usuario_set_password_simple
  @usuario_id CHAR(36),
  @password   NVARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.usuarios
     SET password_hash = HASHBYTES('SHA2_512', CONVERT(VARBINARY(4000), @password))
   WHERE id = @usuario_id;
  IF @@ROWCOUNT = 0
    RAISERROR('Usuario no encontrado.', 16, 1);
END
GO

-- 2) Procedimiento para verificar login
CREATE OR ALTER PROCEDURE dbo.sp_usuario_login_simple
  @correo   VARCHAR(255),
  @password NVARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @hash VARBINARY(64) = HASHBYTES('SHA2_512', CONVERT(VARBINARY(4000), @password));
  IF EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo = @correo AND password_hash = @hash)
    SELECT CAST(1 AS BIT) AS ok;   -- credenciales válidas
  ELSE
    SELECT CAST(0 AS BIT) AS ok;   -- inválidas
END
GO

-- Test login para 'tobiager@example.com' con contraseña correcta
PRINT 'Intentando login para tobiager@example.com con contraseña correcta (RiverPlate2018!):';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'RiverPlate2018!';

-- Test login para 'tobiager@example.com' con contraseña incorrecta
PRINT 'Intentando login para tobiager@example.com con contraseña incorrecta:';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'ContrasenaFalsa!';

-- Test login para 'ana.ferro@example.com' con contraseña correcta
PRINT 'Intentando login para ana.ferro@example.com con contraseña correcta (VelezSarsfield!):';
EXEC dbo.sp_usuario_login_simple @correo = 'ana.ferro@example.com', @password = N'VelezSarsfield!';

-- Test cambio de contraseña y re-login
PRINT 'Cambiando contraseña para tobiager@example.com a NewRiverPass! y re-intentando login:';
EXEC dbo.sp_usuario_set_password_simple @usuario_id = '11111111-1111-1111-1111-111111111111', @password = N'NewRiverPass!';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'NewRiverPass!';
PRINT 'Intentando login con la contraseña antigua (debería fallar):';
EXEC dbo.sp_usuario_login_simple @correo = 'tobiager@example.com', @password = N'RiverPlate2018!';
GO
