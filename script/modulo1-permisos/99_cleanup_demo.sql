USE tribuneros_bdi;
GO

/* 0) (Opcional) Ver quién es miembro de qué rol */
SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members drm
JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id
WHERE r.name IN ('app_exec','rol_lectura_ligas');

/* 1) Quitar membresías de roles */
IF USER_ID('trib_ro') IS NOT NULL AND IS_ROLEMEMBER('app_exec','trib_ro') = 1
    ALTER ROLE app_exec DROP MEMBER trib_ro;

IF USER_ID('trib_a') IS NOT NULL AND IS_ROLEMEMBER('rol_lectura_ligas','trib_a') = 1
    ALTER ROLE rol_lectura_ligas DROP MEMBER trib_a;

IF USER_ID('trib_b') IS NOT NULL AND IS_ROLEMEMBER('rol_lectura_ligas','trib_b') = 1
    ALTER ROLE rol_lectura_ligas DROP MEMBER trib_b;

-- (prolijidad) sacar de roles fijos
IF USER_ID('trib_admin') IS NOT NULL AND IS_ROLEMEMBER('db_owner','trib_admin') = 1
    ALTER ROLE db_owner DROP MEMBER trib_admin;

IF USER_ID('trib_ro') IS NOT NULL AND IS_ROLEMEMBER('db_datareader','trib_ro') = 1
    ALTER ROLE db_datareader DROP MEMBER trib_ro;

/* 2) Eliminar roles de demo (ya vacíos) */
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_exec')
    DROP ROLE app_exec;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_lectura_ligas')
    DROP ROLE rol_lectura_ligas;

/* 3) (Opcional) Eliminar el SP de demo */
IF OBJECT_ID('dbo.sp_calificacion_insertar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_calificacion_insertar;

/* 4) Eliminar usuarios de la base */
IF USER_ID('trib_admin') IS NOT NULL DROP USER trib_admin;
IF USER_ID('trib_ro')   IS NOT NULL DROP USER trib_ro;
IF USER_ID('trib_a')    IS NOT NULL DROP USER trib_a;
IF USER_ID('trib_b')    IS NOT NULL DROP USER trib_b;
GO

/* 5) Eliminar logins a nivel instancia */
IF SUSER_ID('trib_admin') IS NOT NULL DROP LOGIN trib_admin;
IF SUSER_ID('trib_ro')   IS NOT NULL DROP LOGIN trib_ro;
IF SUSER_ID('trib_a')    IS NOT NULL DROP LOGIN trib_a;
IF SUSER_ID('trib_b')    IS NOT NULL DROP LOGIN trib_b;
GO

/* 6) Verificación (debería devolver 0 filas / NULL) */
USE tribuneros_bdi;
SELECT name, type_desc
FROM sys.database_principals
WHERE name IN ('app_exec','rol_lectura_ligas','trib_admin','trib_ro','trib_a','trib_b');

SELECT OBJECT_ID('dbo.sp_calificacion_insertar','P') AS sp_calificacion_insertar;

SELECT name, type_desc
FROM sys.server_principals
WHERE name IN ('trib_admin','trib_ro','trib_a','trib_b');
