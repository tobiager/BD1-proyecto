-- =========================================================
-- TEMA 1: Manejo de Permisos a Nivel de Usuarios
-- Script 1: Configuración de Usuarios
-- =========================================================
-- Este script configura usuarios de base de datos con diferentes
-- niveles de permisos para demostrar la gestión de seguridad
-- en SQL Server.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- SECCIÓN 1: Verificación de Modo de Autenticación
-- =========================================================
PRINT '==================================================';
PRINT 'VERIFICACIÓN DE MODO DE AUTENTICACIÓN';
PRINT '==================================================';

-- Verificar si el servidor está en modo mixto (Windows + SQL Server)
-- Valor 0 = Solo Windows, Valor 1 = Modo Mixto
DECLARE @AuthMode INT;
EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', 
    @AuthMode OUTPUT;

IF @AuthMode = 1
BEGIN
    PRINT 'MODO DE AUTENTICACIÓN: Mixto (Windows + SQL Server)';
    PRINT 'El servidor está correctamente configurado para autenticación mixta.';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: El servidor está en modo de autenticación solo Windows.';
    PRINT 'Para usar usuarios de SQL Server, debe cambiar a modo mixto.';
    PRINT 'Configuración > Seguridad > Modo de autenticación del servidor';
END
PRINT '';

-- =========================================================
-- SECCIÓN 2: Limpieza de Usuarios Existentes
-- =========================================================
PRINT '==================================================';
PRINT 'LIMPIEZA DE USUARIOS EXISTENTES';
PRINT '==================================================';

-- Eliminar usuarios de BD si existen
IF DATABASE_PRINCIPAL_ID('Admin_Usuario') IS NOT NULL
BEGIN
    DROP USER Admin_Usuario;
    PRINT 'Usuario de BD "Admin_Usuario" eliminado.';
END

IF DATABASE_PRINCIPAL_ID('LecturaSolo_Usuario') IS NOT NULL
BEGIN
    DROP USER LecturaSolo_Usuario;
    PRINT 'Usuario de BD "LecturaSolo_Usuario" eliminado.';
END

-- Eliminar logins de servidor si existen
IF SUSER_ID('Admin_Usuario') IS NOT NULL
BEGIN
    DROP LOGIN Admin_Usuario;
    PRINT 'Login de servidor "Admin_Usuario" eliminado.';
END

IF SUSER_ID('LecturaSolo_Usuario') IS NOT NULL
BEGIN
    DROP LOGIN LecturaSolo_Usuario;
    PRINT 'Login de servidor "LecturaSolo_Usuario" eliminado.';
END
PRINT '';

-- =========================================================
-- SECCIÓN 3: Creación de Logins de SQL Server
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE LOGINS DE SERVIDOR';
PRINT '==================================================';

-- Crear login para Admin_Usuario
CREATE LOGIN Admin_Usuario 
    WITH PASSWORD = 'Admin123!', 
    CHECK_POLICY = OFF,
    DEFAULT_DATABASE = tribuneros_bdi;
PRINT 'Login "Admin_Usuario" creado con contraseña.';

-- Crear login para LecturaSolo_Usuario
CREATE LOGIN LecturaSolo_Usuario 
    WITH PASSWORD = 'Lectura123!', 
    CHECK_POLICY = OFF,
    DEFAULT_DATABASE = tribuneros_bdi;
PRINT 'Login "LecturaSolo_Usuario" creado con contraseña.';
PRINT '';

-- =========================================================
-- SECCIÓN 4: Creación de Usuarios de Base de Datos
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE USUARIOS DE BASE DE DATOS';
PRINT '==================================================';

-- Crear usuario de BD para Admin_Usuario
CREATE USER Admin_Usuario FOR LOGIN Admin_Usuario;
PRINT 'Usuario de BD "Admin_Usuario" creado.';

-- Crear usuario de BD para LecturaSolo_Usuario
CREATE USER LecturaSolo_Usuario FOR LOGIN LecturaSolo_Usuario;
PRINT 'Usuario de BD "LecturaSolo_Usuario" creado.';
PRINT '';

-- =========================================================
-- SECCIÓN 5: Asignación de Permisos - Admin_Usuario
-- =========================================================
PRINT '==================================================';
PRINT 'ASIGNACIÓN DE PERMISOS - Admin_Usuario';
PRINT '==================================================';

-- Agregar Admin_Usuario al rol db_owner para permisos completos
ALTER ROLE db_owner ADD MEMBER Admin_Usuario;
PRINT 'Admin_Usuario agregado al rol "db_owner".';
PRINT 'Permisos: Control total sobre la base de datos.';
PRINT '  - SELECT, INSERT, UPDATE, DELETE sobre todas las tablas';
PRINT '  - CREATE, ALTER, DROP objetos de base de datos';
PRINT '  - EXECUTE sobre procedimientos y funciones';
PRINT '';

-- =========================================================
-- SECCIÓN 6: Asignación de Permisos - LecturaSolo_Usuario
-- =========================================================
PRINT '==================================================';
PRINT 'ASIGNACIÓN DE PERMISOS - LecturaSolo_Usuario';
PRINT '==================================================';

-- Agregar LecturaSolo_Usuario al rol db_datareader (solo lectura)
ALTER ROLE db_datareader ADD MEMBER LecturaSolo_Usuario;
PRINT 'LecturaSolo_Usuario agregado al rol "db_datareader".';
PRINT 'Permisos: Solo lectura (SELECT) sobre todas las tablas.';
PRINT '';

-- Nota: Los permisos de EXECUTE sobre procedimientos se asignarán
-- después de crear los procedimientos almacenados en el Tema 2
PRINT 'NOTA: Los permisos de EXECUTE sobre procedimientos almacenados';
PRINT '      se asignarán en el script de procedimientos (Tema 2).';
PRINT '';

-- =========================================================
-- SECCIÓN 7: Verificación de Permisos Asignados
-- =========================================================
PRINT '==================================================';
PRINT 'VERIFICACIÓN DE PERMISOS ASIGNADOS';
PRINT '==================================================';

-- Mostrar roles y permisos de Admin_Usuario
PRINT 'Roles de Admin_Usuario:';
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) = 'Admin_Usuario';
PRINT '';

-- Mostrar roles y permisos de LecturaSolo_Usuario
PRINT 'Roles de LecturaSolo_Usuario:';
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(member_principal_id) = 'LecturaSolo_Usuario';
PRINT '';

-- =========================================================
-- SECCIÓN 8: Resumen de Configuración
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE CONFIGURACIÓN';
PRINT '==================================================';
PRINT 'Usuarios creados exitosamente:';
PRINT '';
PRINT '1. Admin_Usuario';
PRINT '   - Login: Admin_Usuario';
PRINT '   - Contraseña: Admin123!';
PRINT '   - Rol: db_owner';
PRINT '   - Permisos: Control total de la base de datos';
PRINT '';
PRINT '2. LecturaSolo_Usuario';
PRINT '   - Login: LecturaSolo_Usuario';
PRINT '   - Contraseña: Lectura123!';
PRINT '   - Rol: db_datareader';
PRINT '   - Permisos: Solo lectura (SELECT)';
PRINT '';
PRINT 'IMPORTANTE: Guarde estas credenciales de forma segura.';
PRINT 'En un entorno de producción, use contraseñas más seguras.';
PRINT '==================================================';
PRINT 'Script completado exitosamente.';
PRINT '==================================================';
GO
