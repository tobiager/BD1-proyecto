-- =========================================================
-- Tribuneros - Procedimientos con Manejo de Transacciones
-- Tema 3: Manejo de transacciones y transacciones anidadas
-- =========================================================

USE tribuneros_bdi;
GO

-- =====================================================================
-- PROCEDIMIENTO 1: Registrar Usuario Completo (Transacción Simple)
-- =====================================================================
-- Propósito: Crear un usuario y su perfil en una sola transacción atómica
-- Si falla cualquier paso, se revierte todo
-- =====================================================================

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
  SET XACT_ABORT ON; -- Aborta automáticamente la transacción si hay error
  
  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  DECLARE @ErrorState INT;
  
  BEGIN TRY
    BEGIN TRANSACTION;
    
    -- 1. Insertar en tabla usuarios
    INSERT INTO dbo.usuarios (id, correo, password_hash, creado_en)
    VALUES (
      @usuario_id,
      @correo,
      HASHBYTES('SHA2_512', @password),
      SYSDATETIME()
    );
    
    -- 2. Insertar en tabla perfiles
    INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, biografia, creado_en)
    VALUES (
      @usuario_id,
      @nombre_usuario,
      @nombre_mostrar,
      @biografia,
      SYSDATETIME()
    );
    
    COMMIT TRANSACTION;
    
    PRINT 'Usuario registrado exitosamente: ' + @nombre_usuario;
    
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    
    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO


-- =====================================================================
-- PROCEDIMIENTO 2: Calificar y Opinar (Transacción con Validaciones)
-- =====================================================================
-- Propósito: Insertar calificación y opinión de un partido en una transacción
-- Valida que no existan previamente y que el partido esté finalizado
-- =====================================================================

IF OBJECT_ID('dbo.sp_Calificar_y_Opinar') IS NOT NULL
  DROP PROCEDURE dbo.sp_Calificar_y_Opinar;
GO

CREATE PROCEDURE dbo.sp_Calificar_y_Opinar
  @partido_id     INT,
  @usuario_id     CHAR(36),
  @puntaje        SMALLINT,
  @titulo         VARCHAR(120),
  @cuerpo         VARCHAR(4000),
  @tiene_spoilers SMALLINT = 0,
  @calificacion_id INT OUTPUT,
  @opinion_id      INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  
  DECLARE @estado_partido VARCHAR(15);
  DECLARE @ErrorMsg NVARCHAR(500);
  
  BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Validar que el partido existe y está finalizado
    SELECT @estado_partido = estado
    FROM dbo.partidos
    WHERE id = @partido_id;
    
    IF @estado_partido IS NULL
    BEGIN
      SET @ErrorMsg = 'El partido con ID ' + CAST(@partido_id AS VARCHAR) + ' no existe.';
      RAISERROR(@ErrorMsg, 16, 1);
    END
    
    IF @estado_partido <> 'finalizado'
    BEGIN
      SET @ErrorMsg = 'Solo se pueden calificar partidos finalizados. Estado actual: ' + @estado_partido;
      RAISERROR(@ErrorMsg, 16, 1);
    END
    
    -- Validar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_id)
    BEGIN
      RAISERROR('El usuario especificado no existe.', 16, 1);
    END
    
    -- Insertar calificación
    SELECT @calificacion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.calificaciones;
    
    INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en)
    VALUES (@calificacion_id, @partido_id, @usuario_id, @puntaje, SYSDATETIME());
    
    -- Insertar opinión
    SELECT @opinion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.opiniones;
    
    INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en)
    VALUES (@opinion_id, @partido_id, @usuario_id, @titulo, @cuerpo, 1, @tiene_spoilers, SYSDATETIME());
    
    COMMIT TRANSACTION;
    
    PRINT 'Calificación y opinión registradas exitosamente.';
    PRINT 'ID Calificación: ' + CAST(@calificacion_id AS VARCHAR);
    PRINT 'ID Opinión: ' + CAST(@opinion_id AS VARCHAR);
    
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO


-- =====================================================================
-- PROCEDIMIENTO 3: Seguir Equipo y Agregar Recordatorio (Transacción Anidada)
-- =====================================================================
-- Propósito: Agregar seguimiento a un equipo y crear recordatorios para sus próximos partidos
-- Utiliza transacciones anidadas con SAVE TRANSACTION
-- =====================================================================

IF OBJECT_ID('dbo.sp_Seguir_Equipo_Con_Recordatorios') IS NOT NULL
  DROP PROCEDURE dbo.sp_Seguir_Equipo_Con_Recordatorios;
GO

CREATE PROCEDURE dbo.sp_Seguir_Equipo_Con_Recordatorios
  @usuario_id CHAR(36),
  @equipo_id  INT,
  @dias_anticipacion INT = 1 -- Días de anticipación para el recordatorio
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @seguimiento_id INT;
  DECLARE @partido_id INT;
  DECLARE @fecha_partido DATETIME2;
  DECLARE @recordatorio_id INT;
  DECLARE @contador INT = 0;
  
  BEGIN TRY
    BEGIN TRANSACTION TxnPrincipal; -- Transacción externa
    
    -- 1. Agregar seguimiento del equipo
    SELECT @seguimiento_id = ISNULL(MAX(id), 0) + 1 FROM dbo.seguimiento_equipos;
    
    INSERT INTO dbo.seguimiento_equipos (id, usuario_id, equipo_id, creado_en)
    VALUES (@seguimiento_id, @usuario_id, @equipo_id, SYSDATETIME());
    
    PRINT 'Seguimiento agregado para equipo ID: ' + CAST(@equipo_id AS VARCHAR);
    
    -- Punto de guardado antes de insertar recordatorios
    SAVE TRANSACTION SavePointRecordatorios;
    
    -- 2. Crear recordatorios para próximos partidos del equipo
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
        -- Transacción anidada para cada recordatorio
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
        
        SET @contador = @contador + 1;
        
      END TRY
      BEGIN CATCH
        -- Si falla un recordatorio, revertir solo hasta el punto de guardado
        PRINT 'Error al crear recordatorio para partido ' + CAST(@partido_id AS VARCHAR) + ': ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION SavePointRecordatorios;
        SAVE TRANSACTION SavePointRecordatorios; -- Recrear el punto de guardado
      END CATCH
      
      FETCH NEXT FROM cursor_partidos INTO @partido_id, @fecha_partido;
    END
    
    CLOSE cursor_partidos;
    DEALLOCATE cursor_partidos;
    
    COMMIT TRANSACTION TxnPrincipal;
    
    PRINT 'Se crearon ' + CAST(@contador AS VARCHAR) + ' recordatorios para partidos futuros.';
    
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION TxnPrincipal;
    
    IF CURSOR_STATUS('local', 'cursor_partidos') >= 0
    BEGIN
      CLOSE cursor_partidos;
      DEALLOCATE cursor_partidos;
    END
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO


-- =====================================================================
-- PROCEDIMIENTO 4: Registrar Actividad Usuario Completa (INSERT-INSERT-UPDATE)
-- =====================================================================
-- Propósito: Cumple EXACTAMENTE con la Tarea 1 de la consigna:
--   1. INSERT en visualizaciones (registrar que vio el partido)
--   2. INSERT en calificaciones (calificar el partido)
--   3. UPDATE en perfiles (actualizar última actividad)
-- Toda la operación se completa solo si TODAS las operaciones tienen éxito
-- =====================================================================

IF OBJECT_ID('dbo.sp_Registrar_Actividad_Usuario_Completa') IS NOT NULL
  DROP PROCEDURE dbo.sp_Registrar_Actividad_Usuario_Completa;
GO

CREATE PROCEDURE dbo.sp_Registrar_Actividad_Usuario_Completa
  @partido_id INT,
  @usuario_id CHAR(36),
  @medio VARCHAR(12),           -- 'estadio' | 'tv' | 'streaming' | 'repeticion'
  @minutos_vistos INT,
  @puntaje SMALLINT,            -- Calificación de 1 a 5
  @visualizacion_id INT OUTPUT,
  @calificacion_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
  
  DECLARE @ErrorMsg NVARCHAR(500);
  DECLARE @estado_partido VARCHAR(15);
  
  BEGIN TRY
    BEGIN TRANSACTION;
    
    -- ===== VALIDACIONES PREVIAS =====
    
    -- Validar que el partido existe
    SELECT @estado_partido = estado
    FROM dbo.partidos
    WHERE id = @partido_id;
    
    IF @estado_partido IS NULL
    BEGIN
      SET @ErrorMsg = 'El partido con ID ' + CAST(@partido_id AS VARCHAR) + ' no existe.';
      RAISERROR(@ErrorMsg, 16, 1);
    END
    
    -- Validar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE id = @usuario_id)
    BEGIN
      RAISERROR('El usuario especificado no existe.', 16, 1);
    END
    
    -- Validar medio
    IF @medio NOT IN ('estadio', 'tv', 'streaming', 'repeticion')
    BEGIN
      RAISERROR('Medio inválido. Debe ser: estadio, tv, streaming o repeticion', 16, 1);
    END
    
    -- Validar puntaje
    IF @puntaje NOT BETWEEN 1 AND 5
    BEGIN
      RAISERROR('El puntaje debe estar entre 1 y 5.', 16, 1);
    END
    
    PRINT '=== Iniciando transacción compleja: INSERT → INSERT → UPDATE ===';
    PRINT '';
    
    -- ===== OPERACIÓN 1: INSERT EN VISUALIZACIONES =====
    SELECT @visualizacion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.visualizaciones;
    
    INSERT INTO dbo.visualizaciones (id, partido_id, usuario_id, medio, visto_en, minutos_vistos, creado_en)
    VALUES (
      @visualizacion_id,
      @partido_id,
      @usuario_id,
      @medio,
      SYSDATETIME(),
      @minutos_vistos,
      SYSDATETIME()
    );
    
    PRINT '✓ PASO 1: INSERT en visualizaciones completado (ID: ' + CAST(@visualizacion_id AS VARCHAR) + ')';
    
    -- ===== OPERACIÓN 2: INSERT EN CALIFICACIONES =====
    SELECT @calificacion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.calificaciones;
    
    INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en)
    VALUES (
      @calificacion_id,
      @partido_id,
      @usuario_id,
      @puntaje,
      SYSDATETIME()
    );
    
    PRINT '✓ PASO 2: INSERT en calificaciones completado (ID: ' + CAST(@calificacion_id AS VARCHAR) + ')';
    
    -- ===== OPERACIÓN 3: UPDATE EN PERFILES =====
    UPDATE dbo.perfiles
    SET actualizado_en = SYSDATETIME()
    WHERE usuario_id = @usuario_id;
    
    IF @@ROWCOUNT = 0
    BEGIN
      RAISERROR('No se pudo actualizar el perfil del usuario.', 16, 1);
    END
    
    PRINT '✓ PASO 3: UPDATE en perfiles completado (última actividad actualizada)';
    PRINT '';
    
    -- ===== COMMIT FINAL =====
    COMMIT TRANSACTION;
    
    PRINT '=== TRANSACCIÓN COMPLETADA CON ÉXITO ===';
    PRINT 'Todas las operaciones (INSERT → INSERT → UPDATE) se realizaron correctamente.';
    PRINT 'Visualización ID: ' + CAST(@visualizacion_id AS VARCHAR);
    PRINT 'Calificación ID: ' + CAST(@calificacion_id AS VARCHAR);
    
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
      PRINT '';
      PRINT '✗ ERROR DETECTADO - ROLLBACK EJECUTADO';
      PRINT 'NINGUNA de las operaciones fue realizada (INSERT-INSERT-UPDATE revertidos)';
    END
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO

PRINT 'Procedimientos transaccionales creados exitosamente.';
GO
