-- SP de ejemplo (tabla: calificaciones)
CREATE OR ALTER PROCEDURE dbo.sp_calificacion_insertar
  @partido_id INT,
  @usuario_id CHAR(36),
  @puntaje    SMALLINT
WITH EXECUTE AS OWNER
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @id INT = (SELECT ISNULL(MAX(id),0)+1 FROM dbo.calificaciones WITH (TABLOCKX));
  INSERT dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en)
  VALUES (@id, @partido_id, @usuario_id, @puntaje, SYSUTCDATETIME());
END
GO

-- Rol para centralizar EXECUTE y dárselo al usuario de solo lectura
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='app_exec')
  CREATE ROLE app_exec AUTHORIZATION dbo;

GRANT EXECUTE ON OBJECT::dbo.sp_calificacion_insertar TO app_exec;
ALTER ROLE app_exec ADD MEMBER trib_ro;
GO
