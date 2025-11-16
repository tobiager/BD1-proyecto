-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 01_procedimientos.sql 
-- =================================================================
USE tribuneros_bdi;
GO

-------------------------------------------------------------------
-- 1. Procedimiento para INSERTAR una nueva opinión
-- Nota: dbo.opiniones.id es IDENTITY, usuario_id es INT, publica/tiene_spoilers son BIT.
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Insertar_Opinion
    @partido_id INT,
    @usuario_id INT,
    @titulo NVARCHAR(120),
    @cuerpo NVARCHAR(2000),
    @publica BIT,
    @tiene_spoilers BIT,
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

    INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
    VALUES (@partido_id, @usuario_id, @titulo, @cuerpo, @publica, @tiene_spoilers, SYSDATETIME(), NULL);

    SET @opinion_id = CAST(SCOPE_IDENTITY() AS INT);
END;
GO

-------------------------------------------------------------------
-- 2. Procedimiento para MODIFICAR una opinión existente
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Modificar_Opinion
    @opinion_id INT,
    @usuario_id INT, -- Para verificar que el usuario es el dueño
    @titulo NVARCHAR(120),
    @cuerpo NVARCHAR(2000),
    @publica BIT,
    @tiene_spoilers BIT
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
    @usuario_id INT -- Para verificar que el usuario es el dueño
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