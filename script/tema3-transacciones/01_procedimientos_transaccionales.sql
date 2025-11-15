-- =========================================================
-- Archivo: 01_procedimientos_transaccionales.sql
-- Contiene los 4 procedimientos transaccionales principales
-- =========================================================

USE tribuneros_bdi;
GO

-------------------------------------------------------------
-- PROCEDIMIENTO 1: sp_Registrar_Usuario_Completo
-------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Registrar_Usuario_Completo') IS NOT NULL
  DROP PROCEDURE dbo.sp_Registrar_Usuario_Completo;
GO

CREATE PROCEDURE dbo.sp_Registrar_Usuario_Completo
  @usuario_id     CHAR(36),
  @correo         VARCHAR(255),
  @password       VARCHAR(255),
  @nombre_usuario VARCHAR(30),
  @nombre_mostrar VARCHAR(60) = NULL,
  @biografia      VARCHAR(400) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  DECLARE @ErrorState INT;

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.usuarios (id, correo, password_hash, creado_en)
    VALUES (@usuario_id, @correo, HASHBYTES('SHA2_512', @password), SYSDATETIME());

    INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, biografia, creado_en)
    VALUES (@usuario_id, @nombre_usuario, @nombre_mostrar, @biografia, SYSDATETIME());

    COMMIT TRANSACTION;
    PRINT 'Usuario registrado exitosamente: ' + @nombre_usuario;

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO


-------------------------------------------------------------
-- PROCEDIMIENTO 2: sp_Calificar_y_Opinar
-------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Calificar_y_Opinar') IS NOT NULL
  DROP PROCEDURE dbo.sp_Calificar_y_Opinar;
GO

CREATE PROCEDURE dbo.sp_Calificar_y_Opinar
  @partido_id INT,
  @usuario_id CHAR(36),
  @puntaje SMALLINT,
  @titulo VARCHAR(120),
  @cuerpo VARCHAR(4000),
  @tiene_spoilers SMALLINT = 0,
  @calificacion_id INT OUTPUT,
  @opinion_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  DECLARE @estado_partido VARCHAR(15);
  DECLARE @ErrorMsg NVARCHAR(500);

  BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @estado_partido = estado
    FROM dbo.partidos
    WHERE id = @partido_id;

    IF @estado_partido IS NULL
      RAISERROR('El partido no existe.', 16, 1);

    IF @estado_partido <> 'finalizado'
      RAISERROR('El partido no está finalizado.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_id)
      RAISERROR('El usuario no existe.', 16, 1);

    SELECT @calificacion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.calificaciones;

    INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en)
    VALUES (@calificacion_id, @partido_id, @usuario_id, @puntaje, SYSDATETIME());

    SELECT @opinion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.opiniones;

    INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en)
    VALUES (@opinion_id, @partido_id, @usuario_id, @titulo, @cuerpo, 1, @tiene_spoilers, SYSDATETIME());

    COMMIT TRANSACTION;

    PRINT 'Calificación y opinión registradas exitosamente.';
    PRINT 'ID Calificación: ' + CAST(@calificacion_id AS VARCHAR);
    PRINT 'ID Opinión: ' + CAST(@opinion_id AS VARCHAR);

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    RAISERROR(ERROR_MESSAGE(), ERROR_SEVERITY(), ERROR_STATE());
  END CATCH
END;
GO


-------------------------------------------------------------
-- PROCEDIMIENTO 3: sp_Seguir_Equipo_Con_Recordatorios
-------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Seguir_Equipo_Con_Recordatorios') IS NOT NULL
  DROP PROCEDURE dbo.sp_Seguir_Equipo_Con_Recordatorios;
GO

CREATE PROCEDURE dbo.sp_Seguir_Equipo_Con_Recordatorios
  @usuario_id CHAR(36),
  @equipo_id INT,
  @dias_anticipacion INT = 1
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @seguimiento_id INT;
  DECLARE @partido_id INT;
  DECLARE @fecha_partido DATETIME2;
  DECLARE @recordatorio_id INT;
  DECLARE @contador INT = 0;

  BEGIN TRY
    BEGIN TRANSACTION TxnPrincipal;

    SELECT @seguimiento_id = ISNULL(MAX(id),0) + 1 FROM dbo.seguimiento_equipos;

    INSERT INTO dbo.seguimiento_equipos (id, usuario_id, equipo_id, creado_en)
    VALUES (@seguimiento_id, @usuario_id, @equipo_id, SYSDATETIME());

    PRINT 'Seguimiento agregado para equipo ID: ' + CAST(@equipo_id AS VARCHAR);

    SAVE TRANSACTION SavePointRecordatorios;

    DECLARE cursor_partidos CURSOR FOR
      SELECT id, fecha_utc
      FROM dbo.partidos
      WHERE (equipo_local = @equipo_id OR equipo_visitante = @equipo_id)
        AND estado = 'programado'
        AND fecha_utc > SYSDATETIME();

    OPEN cursor_partidos;
    FETCH NEXT FROM cursor_partidos INTO @partido_id, @fecha_partido;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      BEGIN TRY
        SELECT @recordatorio_id = ISNULL(MAX(id), 0) + 1 FROM dbo.recordatorios;

        INSERT INTO dbo.recordatorios (id, usuario_id, partido_id, recordar_en, estado, creado_en)
        VALUES (
          @recordatorio_id,
          @usuario_id,
          @partido_id,
          DATEADD(DAY, -@dias_anticipacion, @fecha_partido),
          'pendiente',
          SYSDATETIME()
        );

        SET @contador += 1;

      END TRY
      BEGIN CATCH
        PRINT 'Error al crear recordatorio para partido ' + CAST(@partido_id AS VARCHAR) + ': ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION SavePointRecordatorios;
        SAVE TRANSACTION SavePointRecordatorios;
      END CATCH

      FETCH NEXT FROM cursor_partidos INTO @partido_id, @fecha_partido;
    END

    CLOSE cursor_partidos;
    DEALLOCATE cursor_partidos;

    COMMIT TRANSACTION TxnPrincipal;

    PRINT 'Se crearon ' + CAST(@contador AS VARCHAR) + ' recordatorios para partidos futuros.';

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION TxnPrincipal;

    IF CURSOR_STATUS('local', 'cursor_partidos') >= 0
    BEGIN
      CLOSE cursor_partidos;
      DEALLOCATE cursor_partidos;
    END

    RAISERROR(ERROR_MESSAGE(), ERROR_SEVERITY(), ERROR_STATE());
  END CATCH
END;
GO


-------------------------------------------------------------
-- PROCEDIMIENTO 4: sp_Transferir_Favoritos
-------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Transferir_Favoritos') IS NOT NULL
  DROP PROCEDURE dbo.sp_Transferir_Favoritos;
GO

CREATE PROCEDURE dbo.sp_Transferir_Favoritos
  @usuario_origen CHAR(36),
  @usuario_destino CHAR(36),
  @sobrescribir BIT = 0
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;

  DECLARE @favoritos_copiados INT = 0;
  DECLARE @favoritos_origen INT;

  BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_origen)
      RAISERROR('El usuario origen no existe.', 16, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_destino)
      RAISERROR('El usuario destino no existe.', 16, 1);

    IF @usuario_origen = @usuario_destino
      RAISERROR('El usuario origen y destino no pueden ser el mismo.', 16, 1);

    SELECT @favoritos_origen = COUNT(*) 
    FROM dbo.favoritos 
    WHERE usuario_id = @usuario_origen;

    IF @favoritos_origen = 0
    BEGIN
      PRINT 'El usuario origen no tiene favoritos para transferir.';
      COMMIT TRANSACTION;
      RETURN;
    END

    IF @sobrescribir = 1
    BEGIN
      DELETE FROM dbo.favoritos WHERE usuario_id = @usuario_destino;
      PRINT 'Favoritos existentes del usuario destino eliminados.';
    END

    INSERT INTO dbo.favoritos (id, partido_id, usuario_id, creado_en)
    SELECT 
      (SELECT ISNULL(MAX(id), 0) FROM dbo.favoritos) + ROW_NUMBER() OVER (ORDER BY f.creado_en),
      f.partido_id,
      @usuario_destino,
      SYSDATETIME()
    FROM dbo.favoritos f
    WHERE f.usuario_id = @usuario_origen
      AND NOT EXISTS (
        SELECT 1 
        FROM dbo.favoritos f2 
        WHERE f2.usuario_id = @usuario_destino 
          AND f2.partido_id = f.partido_id
      );

    SET @favoritos_copiados = @@ROWCOUNT;

    COMMIT TRANSACTION;

    PRINT 'Transferencia completada:';
    PRINT '  - Favoritos en origen: ' + CAST(@favoritos_origen AS VARCHAR);
    PRINT '  - Favoritos copiados: ' + CAST(@favoritos_copiados AS VARCHAR);

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    RAISERROR(ERROR_MESSAGE(), ERROR_SEVERITY(), ERROR_STATE());
  END CATCH
END;
GO


PRINT 'Procedimientos transaccionales creados exitosamente.';
GO
