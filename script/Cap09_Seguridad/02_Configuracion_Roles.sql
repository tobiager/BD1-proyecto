-- =========================================================
-- TEMA 1: Manejo de Permisos a Nivel de Roles
-- Script 2: Configuración de Roles
-- =========================================================
-- Este script configura roles personalizados y demuestra
-- la gestión de permisos a través de roles en SQL Server.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- SECCIÓN 1: Limpieza de Usuarios y Roles Existentes
-- =========================================================
PRINT '==================================================';
PRINT 'LIMPIEZA DE USUARIOS Y ROLES EXISTENTES';
PRINT '==================================================';

-- Eliminar usuarios de BD si existen
IF DATABASE_PRINCIPAL_ID('Usuario_ConRol') IS NOT NULL
BEGIN
    DROP USER Usuario_ConRol;
    PRINT 'Usuario de BD "Usuario_ConRol" eliminado.';
END

IF DATABASE_PRINCIPAL_ID('Usuario_SinRol') IS NOT NULL
BEGIN
    DROP USER Usuario_SinRol;
    PRINT 'Usuario de BD "Usuario_SinRol" eliminado.';
END

-- Eliminar logins de servidor si existen
IF SUSER_ID('Usuario_ConRol') IS NOT NULL
BEGIN
    DROP LOGIN Usuario_ConRol;
    PRINT 'Login "Usuario_ConRol" eliminado.';
END

IF SUSER_ID('Usuario_SinRol') IS NOT NULL
BEGIN
    DROP LOGIN Usuario_SinRol;
    PRINT 'Login "Usuario_SinRol" eliminado.';
END

-- Eliminar rol personalizado si existe
IF DATABASE_PRINCIPAL_ID('RolLectura') IS NOT NULL
BEGIN
    DROP ROLE RolLectura;
    PRINT 'Rol "RolLectura" eliminado.';
END
PRINT '';

-- =========================================================
-- SECCIÓN 2: Creación de Logins de SQL Server
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE LOGINS DE SERVIDOR';
PRINT '==================================================';

-- Crear login para Usuario_ConRol
CREATE LOGIN Usuario_ConRol 
    WITH PASSWORD = 'ConRol123!', 
    CHECK_POLICY = OFF,
    DEFAULT_DATABASE = tribuneros_bdi;
PRINT 'Login "Usuario_ConRol" creado.';

-- Crear login para Usuario_SinRol
CREATE LOGIN Usuario_SinRol 
    WITH PASSWORD = 'SinRol123!', 
    CHECK_POLICY = OFF,
    DEFAULT_DATABASE = tribuneros_bdi;
PRINT 'Login "Usuario_SinRol" creado.';
PRINT '';

-- =========================================================
-- SECCIÓN 3: Creación de Usuarios de Base de Datos
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE USUARIOS DE BASE DE DATOS';
PRINT '==================================================';

-- Crear usuario de BD para Usuario_ConRol
CREATE USER Usuario_ConRol FOR LOGIN Usuario_ConRol;
PRINT 'Usuario de BD "Usuario_ConRol" creado.';

-- Crear usuario de BD para Usuario_SinRol
CREATE USER Usuario_SinRol FOR LOGIN Usuario_SinRol;
PRINT 'Usuario de BD "Usuario_SinRol" creado.';
PRINT '';

-- =========================================================
-- SECCIÓN 4: Creación de Rol Personalizado
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE ROL PERSONALIZADO - RolLectura';
PRINT '==================================================';

-- Crear rol personalizado para lectura específica
CREATE ROLE RolLectura;
PRINT 'Rol "RolLectura" creado exitosamente.';
PRINT '';

-- =========================================================
-- SECCIÓN 5: Asignación de Permisos al Rol
-- =========================================================
PRINT '==================================================';
PRINT 'ASIGNACIÓN DE PERMISOS AL ROL - RolLectura';
PRINT '==================================================';

-- Otorgar permiso SELECT sobre tabla partidos
GRANT SELECT ON dbo.partidos TO RolLectura;
PRINT 'Permiso SELECT otorgado sobre tabla "partidos".';

-- Otorgar permiso SELECT sobre tabla equipos
GRANT SELECT ON dbo.equipos TO RolLectura;
PRINT 'Permiso SELECT otorgado sobre tabla "equipos".';

-- Otorgar permiso SELECT sobre tabla ligas
GRANT SELECT ON dbo.ligas TO RolLectura;
PRINT 'Permiso SELECT otorgado sobre tabla "ligas".';

PRINT '';
PRINT 'Resumen de permisos del RolLectura:';
PRINT '  - SELECT sobre dbo.partidos';
PRINT '  - SELECT sobre dbo.equipos';
PRINT '  - SELECT sobre dbo.ligas';
PRINT '  - Sin acceso a otras tablas (usuarios, calificaciones, etc.)';
PRINT '';

-- =========================================================
-- SECCIÓN 6: Asignación de Rol a Usuario_ConRol
-- =========================================================
PRINT '==================================================';
PRINT 'ASIGNACIÓN DE ROL A USUARIO_ConRol';
PRINT '==================================================';

-- Agregar Usuario_ConRol al rol RolLectura
ALTER ROLE RolLectura ADD MEMBER Usuario_ConRol;
PRINT 'Usuario_ConRol agregado al rol "RolLectura".';
PRINT 'Este usuario puede consultar: partidos, equipos y ligas.';
PRINT '';

-- =========================================================
-- SECCIÓN 7: Usuario_SinRol sin Permisos
-- =========================================================
PRINT '==================================================';
PRINT 'CONFIGURACIÓN DE Usuario_SinRol';
PRINT '==================================================';

PRINT 'Usuario_SinRol creado sin permisos adicionales.';
PRINT 'Este usuario tiene acceso mínimo (solo public).';
PRINT 'No puede consultar ninguna tabla específica.';
PRINT '';

-- =========================================================
-- SECCIÓN 8: Verificación de Configuración
-- =========================================================
PRINT '==================================================';
PRINT 'VERIFICACIÓN DE CONFIGURACIÓN';
PRINT '==================================================';

-- Verificar miembros del rol RolLectura
PRINT 'Miembros del rol RolLectura:';
SELECT 
    USER_NAME(member_principal_id) AS Usuario,
    USER_NAME(role_principal_id) AS Rol
FROM sys.database_role_members
WHERE USER_NAME(role_principal_id) = 'RolLectura';
PRINT '';

-- Verificar permisos del rol RolLectura
PRINT 'Permisos del rol RolLectura:';
SELECT 
    pr.name AS Rol,
    OBJECT_NAME(p.major_id) AS Objeto,
    p.permission_name AS Permiso,
    p.state_desc AS Estado
FROM sys.database_permissions p
INNER JOIN sys.database_principals pr ON p.grantee_principal_id = pr.principal_id
WHERE pr.name = 'RolLectura'
ORDER BY Objeto, Permiso;
PRINT '';

-- =========================================================
-- SECCIÓN 9: Resumen de Configuración
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE CONFIGURACIÓN';
PRINT '==================================================';
PRINT 'Usuarios y roles configurados:';
PRINT '';
PRINT '1. Usuario_ConRol';
PRINT '   - Login: Usuario_ConRol';
PRINT '   - Contraseña: ConRol123!';
PRINT '   - Rol: RolLectura';
PRINT '   - Permisos: SELECT sobre partidos, equipos y ligas';
PRINT '';
PRINT '2. Usuario_SinRol';
PRINT '   - Login: Usuario_SinRol';
PRINT '   - Contraseña: SinRol123!';
PRINT '   - Rol: Ninguno (solo public)';
PRINT '   - Permisos: Ninguno sobre tablas específicas';
PRINT '';
PRINT '3. RolLectura (Rol personalizado)';
PRINT '   - Permisos: SELECT sobre partidos, equipos, ligas';
PRINT '   - Miembros: Usuario_ConRol';
PRINT '';
PRINT '==================================================';
PRINT 'Script completado exitosamente.';
PRINT '==================================================';
GO
