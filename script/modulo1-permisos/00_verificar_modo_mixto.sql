-- Verifica modo de autenticación de la instancia
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
         WHEN 1 THEN 'Windows-only'
         ELSE 'Mixed (SQL + Windows)'
       END AS auth_mode;
GO

-- (Opcional, requiere sysadmin y luego reiniciar servicio)
-- EXEC xp_instance_regwrite
--   N'HKEY_LOCAL_MACHINE',
--   N'Software\Microsoft\MSSQLServer\MSSQLServer',
--   N'LoginMode', REG_DWORD, 2;
