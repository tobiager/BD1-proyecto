-- (Instancia) crea 2 logins con política de complejidad
IF SUSER_ID('trib_admin') IS NULL
  CREATE LOGIN trib_admin 
  WITH PASSWORD='contraseñaAdmin', CHECK_POLICY=ON, CHECK_EXPIRATION=ON, 
       DEFAULT_DATABASE=tribuneros_bdi;

IF SUSER_ID('trib_ro') IS NULL
  CREATE LOGIN trib_ro    
  WITH PASSWORD='contraseñaLectura',  CHECK_POLICY=ON, CHECK_EXPIRATION=OFF, 
       DEFAULT_DATABASE=tribuneros_bdi;
GO

-- (Base de datos) mapeo a usuarios
USE tribuneros_bdi;
IF USER_ID('trib_admin') IS NULL CREATE USER trib_admin FOR LOGIN trib_admin;
IF USER_ID('trib_ro')   IS NULL CREATE USER trib_ro    FOR LOGIN trib_ro;

-- Permisos
ALTER ROLE db_owner      ADD MEMBER trib_admin;   -- admin total
ALTER ROLE db_datareader ADD MEMBER trib_ro;      -- solo lectura
GO
