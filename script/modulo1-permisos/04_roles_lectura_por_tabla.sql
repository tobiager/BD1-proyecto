-- Crear dos logins/usuarios nuevos para probar roles por tabla
IF SUSER_ID('trib_a') IS NULL CREATE LOGIN trib_a WITH PASSWORD='P@ssw0rd-A!', DEFAULT_DATABASE=tribuneros_bdi;
IF SUSER_ID('trib_b') IS NULL CREATE LOGIN trib_b WITH PASSWORD='P@ssw0rd-B!', DEFAULT_DATABASE=tribuneros_bdi;
GO
USE tribuneros_bdi;
IF USER_ID('trib_a') IS NULL CREATE USER trib_a FOR LOGIN trib_a;
IF USER_ID('trib_b') IS NULL CREATE USER trib_b FOR LOGIN trib_b;

-- Rol con lectura SOLO sobre dbo.ligas
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='rol_lectura_ligas')
  CREATE ROLE rol_lectura_ligas AUTHORIZATION dbo;

GRANT SELECT ON OBJECT::dbo.ligas TO rol_lectura_ligas;
ALTER ROLE rol_lectura_ligas ADD MEMBER trib_a;   -- trib_a SÍ puede leer ligas; trib_b NO
GO

-- Pruebas
EXECUTE AS LOGIN='trib_a'; SELECT TOP 3 * FROM dbo.ligas; REVERT;   -- OK
EXECUTE AS LOGIN='trib_b';
BEGIN TRY
  SELECT TOP 3 * FROM dbo.ligas; -- debe fallar
END TRY
BEGIN CATCH
  SELECT 'SELECT ligas con trib_b: ERROR (esperado)' AS caso, ERROR_MESSAGE() AS detalle;
END CATCH
REVERT;
