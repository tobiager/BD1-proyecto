-- =========================================================
-- TEMA 2: Procedimientos Almacenados
-- Script 1: Creación de Procedimientos
-- =========================================================
-- Este script crea procedimientos almacenados para operaciones
-- CRUD sobre la tabla partidos con validaciones de negocio.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- SECCIÓN 1: Limpieza de Procedimientos Existentes
-- =========================================================
PRINT '==================================================';
PRINT 'LIMPIEZA DE PROCEDIMIENTOS EXISTENTES';
PRINT '==================================================';

IF OBJECT_ID('dbo.sp_InsertPartido', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_InsertPartido;
    PRINT 'Procedimiento "sp_InsertPartido" eliminado.';
END

IF OBJECT_ID('dbo.sp_UpdatePartido', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_UpdatePartido;
    PRINT 'Procedimiento "sp_UpdatePartido" eliminado.';
END

IF OBJECT_ID('dbo.sp_DeletePartido', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_DeletePartido;
    PRINT 'Procedimiento "sp_DeletePartido" eliminado.';
END
PRINT '';

-- =========================================================
-- SECCIÓN 2: Procedimiento sp_InsertPartido
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE PROCEDIMIENTO: sp_InsertPartido';
PRINT '==================================================';
GO

CREATE PROCEDURE dbo.sp_InsertPartido
    @id INT,
    @id_externo VARCHAR(80) = NULL,
    @liga_id INT = NULL,
    @temporada INT = NULL,
    @ronda VARCHAR(40) = NULL,
    @fecha_utc DATETIME2,
    @estado VARCHAR(15),
    @estadio VARCHAR(120) = NULL,
    @equipo_local INT,
    @equipo_visitante INT,
    @goles_local INT = NULL,
    @goles_visitante INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Iniciar transacción
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: El ID no debe existir
        IF EXISTS (SELECT 1 FROM dbo.partidos WHERE id = @id)
        BEGIN
            RAISERROR('Error: Ya existe un partido con ID %d.', 16, 1, @id);
            RETURN -1;
        END
        
        -- Validación 2: Los equipos deben ser diferentes
        IF @equipo_local = @equipo_visitante
        BEGIN
            RAISERROR('Error: El equipo local y visitante deben ser diferentes.', 16, 1);
            RETURN -2;
        END
        
        -- Validación 3: El equipo local debe existir
        IF NOT EXISTS (SELECT 1 FROM dbo.equipos WHERE id = @equipo_local)
        BEGIN
            RAISERROR('Error: El equipo local con ID %d no existe.', 16, 1, @equipo_local);
            RETURN -3;
        END
        
        -- Validación 4: El equipo visitante debe existir
        IF NOT EXISTS (SELECT 1 FROM dbo.equipos WHERE id = @equipo_visitante)
        BEGIN
            RAISERROR('Error: El equipo visitante con ID %d no existe.', 16, 1, @equipo_visitante);
            RETURN -4;
        END
        
        -- Validación 5: Si se proporciona liga_id, debe existir
        IF @liga_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ligas WHERE id = @liga_id)
        BEGIN
            RAISERROR('Error: La liga con ID %d no existe.', 16, 1, @liga_id);
            RETURN -5;
        END
        
        -- Validación 6: El estado debe ser válido
        IF @estado NOT IN ('programado', 'en_vivo', 'finalizado', 'pospuesto', 'cancelado')
        BEGIN
            RAISERROR('Error: Estado inválido "%s". Debe ser: programado, en_vivo, finalizado, pospuesto o cancelado.', 16, 1, @estado);
            RETURN -6;
        END
        
        -- Validación 7: Si el partido está finalizado, debe tener goles
        IF @estado = 'finalizado' AND (@goles_local IS NULL OR @goles_visitante IS NULL)
        BEGIN
            RAISERROR('Error: Un partido finalizado debe tener los goles de ambos equipos.', 16, 1);
            RETURN -7;
        END
        
        -- Validación 8: Los goles no pueden ser negativos
        IF (@goles_local IS NOT NULL AND @goles_local < 0) OR (@goles_visitante IS NOT NULL AND @goles_visitante < 0)
        BEGIN
            RAISERROR('Error: Los goles no pueden ser negativos.', 16, 1);
            RETURN -8;
        END
        
        -- Insertar el partido
        INSERT INTO dbo.partidos (
            id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio,
            equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
        ) VALUES (
            @id, @id_externo, @liga_id, @temporada, @ronda, @fecha_utc, @estado, @estadio,
            @equipo_local, @equipo_visitante, @goles_local, @goles_visitante, SYSDATETIME()
        );
        
        -- Confirmar transacción
        COMMIT TRANSACTION;
        
        PRINT 'Partido insertado exitosamente con ID: ' + CAST(@id AS VARCHAR(10));
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Revertir transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Registrar error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

PRINT 'Procedimiento "sp_InsertPartido" creado exitosamente.';
PRINT '';

-- =========================================================
-- SECCIÓN 3: Procedimiento sp_UpdatePartido
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE PROCEDIMIENTO: sp_UpdatePartido';
PRINT '==================================================';
GO

CREATE PROCEDURE dbo.sp_UpdatePartido
    @id INT,
    @estado VARCHAR(15) = NULL,
    @goles_local INT = NULL,
    @goles_visitante INT = NULL,
    @estadio VARCHAR(120) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Iniciar transacción
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: El partido debe existir
        IF NOT EXISTS (SELECT 1 FROM dbo.partidos WHERE id = @id)
        BEGIN
            RAISERROR('Error: No existe un partido con ID %d.', 16, 1, @id);
            RETURN -1;
        END
        
        -- Validación 2: Si se proporciona estado, debe ser válido
        IF @estado IS NOT NULL AND @estado NOT IN ('programado', 'en_vivo', 'finalizado', 'pospuesto', 'cancelado')
        BEGIN
            RAISERROR('Error: Estado inválido "%s".', 16, 1, @estado);
            RETURN -2;
        END
        
        -- Validación 3: Los goles no pueden ser negativos
        IF (@goles_local IS NOT NULL AND @goles_local < 0) OR (@goles_visitante IS NOT NULL AND @goles_visitante < 0)
        BEGIN
            RAISERROR('Error: Los goles no pueden ser negativos.', 16, 1);
            RETURN -3;
        END
        
        -- Validación 4: Si se marca como finalizado, debe tener ambos goles
        IF @estado = 'finalizado'
        BEGIN
            DECLARE @goles_l INT, @goles_v INT;
            
            SELECT @goles_l = ISNULL(@goles_local, goles_local),
                   @goles_v = ISNULL(@goles_visitante, goles_visitante)
            FROM dbo.partidos
            WHERE id = @id;
            
            IF @goles_l IS NULL OR @goles_v IS NULL
            BEGIN
                RAISERROR('Error: Para marcar como finalizado, debe especificar ambos goles.', 16, 1);
                RETURN -4;
            END
        END
        
        -- Actualizar el partido (solo campos no nulos)
        UPDATE dbo.partidos
        SET 
            estado = ISNULL(@estado, estado),
            goles_local = ISNULL(@goles_local, goles_local),
            goles_visitante = ISNULL(@goles_visitante, goles_visitante),
            estadio = ISNULL(@estadio, estadio)
        WHERE id = @id;
        
        -- Confirmar transacción
        COMMIT TRANSACTION;
        
        PRINT 'Partido actualizado exitosamente con ID: ' + CAST(@id AS VARCHAR(10));
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Revertir transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Registrar error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

PRINT 'Procedimiento "sp_UpdatePartido" creado exitosamente.';
PRINT '';

-- =========================================================
-- SECCIÓN 4: Procedimiento sp_DeletePartido
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE PROCEDIMIENTO: sp_DeletePartido';
PRINT '==================================================';
GO

CREATE PROCEDURE dbo.sp_DeletePartido
    @id INT,
    @eliminacion_fisica BIT = 0  -- 0 = lógica (cambiar estado), 1 = física
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Iniciar transacción
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: El partido debe existir
        IF NOT EXISTS (SELECT 1 FROM dbo.partidos WHERE id = @id)
        BEGIN
            RAISERROR('Error: No existe un partido con ID %d.', 16, 1, @id);
            RETURN -1;
        END
        
        IF @eliminacion_fisica = 0
        BEGIN
            -- Eliminación LÓGICA: cambiar estado a 'cancelado'
            UPDATE dbo.partidos
            SET estado = 'cancelado'
            WHERE id = @id;
            
            PRINT 'Partido marcado como cancelado (eliminación lógica) con ID: ' + CAST(@id AS VARCHAR(10));
        END
        ELSE
        BEGIN
            -- Eliminación FÍSICA: borrar el registro
            -- Nota: Esto eliminará en cascada las referencias (calificaciones, opiniones, etc.)
            DELETE FROM dbo.partidos WHERE id = @id;
            
            PRINT 'Partido eliminado físicamente con ID: ' + CAST(@id AS VARCHAR(10));
            PRINT 'ADVERTENCIA: Se eliminaron también todas las referencias asociadas (CASCADE).';
        END
        
        -- Confirmar transacción
        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Revertir transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Registrar error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -99;
    END CATCH
END
GO

PRINT 'Procedimiento "sp_DeletePartido" creado exitosamente.';
PRINT '';

-- =========================================================
-- SECCIÓN 5: Otorgar Permisos de EXECUTE
-- =========================================================
PRINT '==================================================';
PRINT 'OTORGAR PERMISOS DE EXECUTE';
PRINT '==================================================';

-- Otorgar permiso EXECUTE a LecturaSolo_Usuario
GRANT EXECUTE ON dbo.sp_InsertPartido TO LecturaSolo_Usuario;
GRANT EXECUTE ON dbo.sp_UpdatePartido TO LecturaSolo_Usuario;
GRANT EXECUTE ON dbo.sp_DeletePartido TO LecturaSolo_Usuario;

PRINT 'Permisos de EXECUTE otorgados a LecturaSolo_Usuario.';
PRINT 'Este usuario ahora puede insertar, actualizar y eliminar a través de SPs.';
PRINT '';

-- =========================================================
-- SECCIÓN 6: Resumen de Procedimientos Creados
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE PROCEDIMIENTOS CREADOS';
PRINT '==================================================';
PRINT '';
PRINT 'Procedimientos almacenados:';
PRINT '';
PRINT '1. sp_InsertPartido';
PRINT '   - Parámetros: @id, @liga_id, @temporada, @ronda, @fecha_utc,';
PRINT '                 @estado, @estadio, @equipo_local, @equipo_visitante,';
PRINT '                 @goles_local, @goles_visitante';
PRINT '   - Validaciones: ID único, equipos diferentes, equipos existentes,';
PRINT '                   estado válido, goles para finalizados';
PRINT '   - Retorno: 0 = éxito, negativo = error';
PRINT '';
PRINT '2. sp_UpdatePartido';
PRINT '   - Parámetros: @id (requerido), @estado, @goles_local,';
PRINT '                 @goles_visitante, @estadio';
PRINT '   - Validaciones: Partido existe, estado válido, goles válidos';
PRINT '   - Retorno: 0 = éxito, negativo = error';
PRINT '';
PRINT '3. sp_DeletePartido';
PRINT '   - Parámetros: @id (requerido), @eliminacion_fisica (0/1)';
PRINT '   - Comportamiento: Lógica (estado=cancelado) o Física (DELETE)';
PRINT '   - Retorno: 0 = éxito, negativo = error';
PRINT '';
PRINT 'Permisos:';
PRINT '   - LecturaSolo_Usuario: EXECUTE sobre todos los procedimientos';
PRINT '';
PRINT '==================================================';
PRINT 'Script completado exitosamente.';
PRINT '==================================================';
GO
