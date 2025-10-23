USE tribuneros_bdi;
GO  

/* ================================================================
   1) Datos fijos para las pruebas (mismos siempre)
================================================================ */
DECLARE @usuario_id  CHAR(36) = '33333333-3333-3333-3333-333333333333';
DECLARE @partido_id  INT;

-- Asegurar usuario demo
IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_id)
BEGIN
  INSERT dbo.usuarios (id, correo, creado_en)
  VALUES (@usuario_id, 'demo+sp@tribuneros.dev', SYSUTCDATETIME());
END

-- Tomar SIEMPRE el mismo partido (primer partido por fecha)
SELECT TOP (1) @partido_id = p.id
FROM dbo.partidos p
ORDER BY p.fecha_utc, p.id;

-- Mostrar contexto usado
SELECT @usuario_id AS usuario_id_usado, @partido_id AS partido_id_usado;

/* ================================================================
   2) Pruebas del módulo
================================================================ */

-- A) trib_ro: SELECT (debe funcionar)
EXECUTE AS LOGIN = 'trib_ro';
SELECT TOP 1 * FROM dbo.ligas ORDER BY id;
REVERT;

-- B) trib_ro: INSERT directo (debe FALLAR por permisos)
EXECUTE AS LOGIN = 'trib_ro';
BEGIN TRY
  INSERT dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en)
  VALUES (
    (SELECT ISNULL(MAX(id),0) + 1 FROM dbo.calificaciones),
    @partido_id, @usuario_id, 4, SYSUTCDATETIME()
  );
END TRY
BEGIN CATCH
  SELECT 'Insert directo trib_ro: ERROR (esperado)' AS caso, ERROR_MESSAGE() AS detalle;
END CATCH;
REVERT;

-- C) trib_ro: INSERT vía SP (debe FUNCIONAR)
EXECUTE AS LOGIN = 'trib_ro';
EXEC dbo.sp_calificacion_insertar
  @partido_id = @partido_id,
  @usuario_id = @usuario_id,
  @puntaje    = 5;
REVERT;

-- Verificación
SELECT TOP 5 id, partido_id, usuario_id, puntaje, creado_en
FROM dbo.calificaciones
ORDER BY id DESC;

/* ================================================================
   3) LIMPIEZA OPCIONAL (para repetir EXACTAMENTE la misma prueba)
   Descomentar y ejecutar SOLO este bloque cuando quieras limpiar.
   (No usa variables → podés correrlo aislado)
================================================================ */

-- DELETE FROM dbo.calificaciones
-- WHERE usuario_id = '33333333-3333-3333-3333-333333333333'
--    AND partido_id = (SELECT TOP 1 id FROM dbo.partidos ORDER BY fecha_utc, id);

-- -- (Opcional) borrar también el usuario demo para dejar todo limpio:
-- DELETE FROM dbo.usuarios
--  WHERE id = '33333333-3333-3333-3333-333333333333';
