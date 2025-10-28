-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 01_procedimientos.sql
--
-- Implementación de procedimientos almacenados para CRUD en la
-- tabla de opiniones.
-- =================================================================
USE tribuneros_bdi;
GO

-------------------------------------------------------------------
-- 1. Procedimiento para INSERTAR una nueva opinión
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Insertar_Opinion
    @partido_id INT,
    @usuario_id CHAR(36),
    @titulo VARCHAR(120),
    @cuerpo VARCHAR(4000),
    @publica SMALLINT,
    @tiene_spoilers SMALLINT,
    @opinion_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el usuario no tenga ya una opinión para este partido
    IF EXISTS (SELECT 1 FROM dbo.opiniones WHERE partido_id = @partido_id AND usuario_id = @usuario_id)
    BEGIN
        RAISERROR('El usuario ya tiene una opinión para este partido.', 16, 1);
        RETURN;
    END

    -- Generar nuevo ID. Nota: En un entorno de alta concurrencia,
    -- es preferible usar una secuencia (SEQUENCE) o IDENTITY.
    SELECT @opinion_id = ISNULL(MAX(id), 0) + 1 FROM dbo.opiniones WITH (TABLOCKX);

    INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
    VALUES (@opinion_id, @partido_id, @usuario_id, @titulo, @cuerpo, @publica, @tiene_spoilers, SYSDATETIME(), NULL);
END;
GO

-------------------------------------------------------------------
-- 2. Procedimiento para MODIFICAR una opinión existente
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Modificar_Opinion
    @opinion_id INT,
    @usuario_id CHAR(36), -- Para verificar que el usuario es el dueño
    @titulo VARCHAR(120),
    @cuerpo VARCHAR(4000),
    @publica SMALLINT,
    @tiene_spoilers SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.opiniones
    SET
        titulo = @titulo,
        cuerpo = @cuerpo,
        publica = @publica,
        tiene_spoilers = @tiene_spoilers,
        actualizado_en = SYSDATETIME()
    WHERE
        id = @opinion_id AND usuario_id = @usuario_id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('La opinión no existe o no tiene permisos para modificarla.', 16, 1);
        RETURN;
    END
END;
GO

-------------------------------------------------------------------
-- 3. Procedimiento para BORRAR una opinión
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Borrar_Opinion
    @opinion_id INT,
    @usuario_id CHAR(36) -- Para verificar que el usuario es el dueño
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.opiniones
    WHERE id = @opinion_id AND usuario_id = @usuario_id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('La opinión no existe o no tiene permisos para borrarla.', 16, 1);
        RETURN;
    END
END;
GO