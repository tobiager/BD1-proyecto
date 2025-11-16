-- =========================================================
-- Tribuneros - Esquema SQL Server 
-- =========================================================

IF DB_ID('tribuneros_bdi') IS NULL
BEGIN
  CREATE DATABASE tribuneros_bdi;
END
GO
USE tribuneros_bdi;
GO

-- Limpieza (orden inverso)
IF OBJECT_ID('dbo.recordatorios')        IS NOT NULL DROP TABLE dbo.recordatorios;
IF OBJECT_ID('dbo.partidos_destacados')  IS NOT NULL DROP TABLE dbo.partidos_destacados;
IF OBJECT_ID('dbo.seguimiento_equipos')  IS NOT NULL DROP TABLE dbo.seguimiento_equipos;
IF OBJECT_ID('dbo.seguimiento_ligas')    IS NOT NULL DROP TABLE dbo.seguimiento_ligas;
IF OBJECT_ID('dbo.seguimiento_usuarios') IS NOT NULL DROP TABLE dbo.seguimiento_usuarios;
IF OBJECT_ID('dbo.visualizaciones')      IS NOT NULL DROP TABLE dbo.visualizaciones;
IF OBJECT_ID('dbo.favoritos')            IS NOT NULL DROP TABLE dbo.favoritos;
IF OBJECT_ID('dbo.opiniones')            IS NOT NULL DROP TABLE dbo.opiniones;
IF OBJECT_ID('dbo.calificaciones')       IS NOT NULL DROP TABLE dbo.calificaciones;
IF OBJECT_ID('dbo.partidos')             IS NOT NULL DROP TABLE dbo.partidos;
IF OBJECT_ID('dbo.equipos')              IS NOT NULL DROP TABLE dbo.equipos;
IF OBJECT_ID('dbo.ligas')                IS NOT NULL DROP TABLE dbo.ligas;
IF OBJECT_ID('dbo.perfiles')             IS NOT NULL DROP TABLE dbo.perfiles;
IF OBJECT_ID('dbo.usuarios')             IS NOT NULL DROP TABLE dbo.usuarios;
GO

/* ===================== 1) Usuarios y perfiles ===================== */
CREATE TABLE dbo.usuarios (
  id             INT               NOT NULL,                     
  correo         VARCHAR(254)     NOT NULL,                    
  password_hash  VARBINARY(64)    NULL,                        -- SHA2_512
  creado_en      DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_usuarios PRIMARY KEY (id),
  CONSTRAINT UQ_usuarios_correo UNIQUE (correo)
);

CREATE TABLE dbo.perfiles (
  usuario_id      INT               NOT NULL,                  
  nombre_usuario  VARCHAR(30)      NOT NULL,                   
  nombre_mostrar  NVARCHAR(60)     NULL,                       
  avatar_url      VARCHAR(400)     NULL,
  biografia       NVARCHAR(400)    NULL,
  creado_en       DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
  actualizado_en  DATETIME2(3)     NULL,
  CONSTRAINT PK_perfiles PRIMARY KEY (usuario_id),
  CONSTRAINT UQ_perfiles_usuario UNIQUE (nombre_usuario),
  CONSTRAINT FK_perfiles_usuario
    FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);
GO

/* ===================== 2) Catálogos ===================== */
CREATE TABLE dbo.ligas (
  id         INT            NOT NULL,
  nombre     NVARCHAR(120)  NOT NULL,
  pais       NVARCHAR(80)   NULL,
  slug       VARCHAR(120)   NULL,
  id_externo VARCHAR(80)    NULL,
  creado_en  DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_ligas PRIMARY KEY (id),
  CONSTRAINT UQ_ligas_slug UNIQUE (slug)
);

CREATE TABLE dbo.equipos (
  id            INT            NOT NULL,
  nombre        NVARCHAR(120)  NOT NULL,
  nombre_corto  NVARCHAR(50)   NULL,
  pais          NVARCHAR(80)   NULL,
  escudo_url    VARCHAR(400)   NULL,
  liga_id       INT            NULL,
  id_externo    VARCHAR(80)    NULL,
  creado_en     DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_equipos PRIMARY KEY (id),
  CONSTRAINT FK_equipos_liga FOREIGN KEY (liga_id)
    REFERENCES dbo.ligas(id) ON DELETE SET NULL
);
GO

/* ===================== 3) Partidos ===================== */
CREATE TABLE dbo.partidos (
  id               INT            NOT NULL,
  id_externo       VARCHAR(80)    NULL,
  liga_id          INT            NULL,
  temporada        SMALLINT       NULL,                      -- año
  ronda            NVARCHAR(40)   NULL,
  fecha_utc        DATETIME2(0)   NOT NULL,                  -- precisión a minuto
  estado           TINYINT        NOT NULL,                  -- 0=prog,1=vivo,2=fin,3=posp,4=canc
  estadio          NVARCHAR(120)  NULL,
  equipo_local     INT            NOT NULL,
  equipo_visitante INT            NOT NULL,
  goles_local      TINYINT        NULL,                      
  goles_visitante  TINYINT        NULL,
  creado_en        DATETIME2(3)   NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_partidos PRIMARY KEY (id),
  CONSTRAINT CK_partidos_estado CHECK (estado IN (0,1,2,3,4)),
  CONSTRAINT CK_partidos_equipos_distintos CHECK (equipo_local <> equipo_visitante),
  CONSTRAINT FK_partidos_liga        FOREIGN KEY (liga_id)          REFERENCES dbo.ligas(id) ON DELETE SET NULL,
  CONSTRAINT FK_partidos_local       FOREIGN KEY (equipo_local)     REFERENCES dbo.equipos(id),
  CONSTRAINT FK_partidos_visitante   FOREIGN KEY (equipo_visitante) REFERENCES dbo.equipos(id)
);

CREATE INDEX IX_partidos_fecha ON dbo.partidos(fecha_utc);
CREATE INDEX IX_partidos_liga  ON dbo.partidos(liga_id);
GO

/* ===================== 4) Interacciones ===================== */
CREATE TABLE dbo.calificaciones (
  id         INT               NOT NULL IDENTITY(1,1),
  partido_id INT               NOT NULL,
  usuario_id INT               NOT NULL,                 
  puntaje    TINYINT           NOT NULL,                      -- 1..5
  creado_en  DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_calificaciones PRIMARY KEY (id),
  CONSTRAINT CK_calif_1_5 CHECK (puntaje BETWEEN 1 AND 5),
  CONSTRAINT UQ_calif UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_calif_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_calif_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.opiniones (
  id             INT               NOT NULL IDENTITY(1,1),
  partido_id     INT               NOT NULL,
  usuario_id     INT               NOT NULL,               
  titulo         NVARCHAR(120)     NULL,
  cuerpo         NVARCHAR(2000)    NULL,                      
  publica        BIT               NOT NULL,                  -- 0/1
  tiene_spoilers BIT               NOT NULL,                  -- 0/1
  creado_en      DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  actualizado_en DATETIME2(3)      NULL,
  CONSTRAINT PK_opiniones PRIMARY KEY (id),
  CONSTRAINT UQ_opiniones UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_opiniones_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_opiniones_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.favoritos (
  id         INT               NOT NULL IDENTITY(1,1),
  partido_id INT               NOT NULL,
  usuario_id INT               NOT NULL,                    
  creado_en  DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_favoritos PRIMARY KEY (id),
  CONSTRAINT UQ_favoritos UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_fav_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_fav_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.visualizaciones (
  id             INT               NOT NULL IDENTITY(1,1),
  partido_id     INT               NOT NULL,
  usuario_id     INT               NOT NULL,                
  medio          TINYINT           NOT NULL,                  -- 0=estadio,1=tv,2=streaming,3=repeticion
  visto_en       DATETIME2(3)      NOT NULL,
  minutos_vistos TINYINT           NULL,                      -- 0..200
  ubicacion      NVARCHAR(120)     NULL,
  creado_en      DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_visualizaciones PRIMARY KEY (id),
  CONSTRAINT CK_vis_medio   CHECK (medio IN (0,1,2,3)),
  CONSTRAINT CK_vis_minutos CHECK (minutos_vistos IS NULL OR minutos_vistos BETWEEN 0 AND 200),
  CONSTRAINT FK_vis_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_vis_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);
GO

/* ===================== 5) Social / Curaduría / Recordatorios ===================== */
CREATE TABLE dbo.seguimiento_equipos (
  id         INT               NOT NULL IDENTITY(1,1),
  usuario_id INT               NOT NULL,                    
  equipo_id  INT               NOT NULL,
  creado_en  DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_seguimiento_equipos PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_equipos UNIQUE (usuario_id, equipo_id),
  CONSTRAINT FK_seg_equipos_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_equipos_equipo FOREIGN KEY (equipo_id)  REFERENCES dbo.equipos(id)  ON DELETE CASCADE
);

CREATE TABLE dbo.seguimiento_ligas (
  id         INT               NOT NULL IDENTITY(1,1),
  usuario_id INT               NOT NULL,                    
  liga_id    INT               NOT NULL,
  creado_en  DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_seguimiento_ligas PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_ligas UNIQUE (usuario_id, liga_id),
  CONSTRAINT FK_seg_ligas_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_ligas_liga FOREIGN KEY (liga_id)    REFERENCES dbo.ligas(id)    ON DELETE CASCADE
);

CREATE TABLE dbo.seguimiento_usuarios (
  id               INT               NOT NULL IDENTITY(1,1),
  usuario_id       INT               NOT NULL,  -- El que sigue 
  usuario_seguido  INT               NOT NULL,  -- El seguido
  creado_en        DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_seguimiento_usuarios PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_usuarios UNIQUE (usuario_id, usuario_seguido),
  CONSTRAINT CK_seg_usuarios_no_self CHECK (usuario_id <> usuario_seguido),
  CONSTRAINT FK_seg_usuarios_seguidor FOREIGN KEY (usuario_id) 
    REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_usuarios_seguido FOREIGN KEY (usuario_seguido) 
    REFERENCES dbo.usuarios(id) ON DELETE NO ACTION
);

CREATE TABLE dbo.partidos_destacados (
  id           INT               NOT NULL IDENTITY(1,1),
  usuario_id   INT               NULL,                     
  partido_id   INT               NOT NULL,
  destacado_en DATE              NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
  nota         NVARCHAR(240)     NULL,
  CONSTRAINT PK_destacados PRIMARY KEY (id),
  CONSTRAINT FK_destacados_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE SET NULL,
  CONSTRAINT FK_destacados_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE
);

CREATE TABLE dbo.recordatorios (
  id          INT               NOT NULL IDENTITY(1,1),
  usuario_id  INT               NOT NULL,                 
  partido_id  INT               NOT NULL,
  recordar_en DATETIME2(3)      NOT NULL,
  estado      TINYINT           NOT NULL,  -- 0=pendiente,1=enviado,2=cancelado
  creado_en   DATETIME2(3)      NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT PK_recordatorios PRIMARY KEY (id),
  CONSTRAINT CK_recordatorios_estado CHECK (estado IN (0,1,2)),
  CONSTRAINT FK_recordatorios_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_recordatorios_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE
);

-- Índices auxiliares (mismo estilo)
CREATE INDEX IX_calif_usuario           ON dbo.calificaciones(usuario_id);
CREATE INDEX IX_opiniones_usuario       ON dbo.opiniones(usuario_id);
CREATE INDEX IX_fav_usuario             ON dbo.favoritos(usuario_id);
CREATE INDEX IX_vis_usuario             ON dbo.visualizaciones(usuario_id);
CREATE INDEX IX_seg_equipos_usuario     ON dbo.seguimiento_equipos(usuario_id);
CREATE INDEX IX_seg_ligas_usuario       ON dbo.seguimiento_ligas(usuario_id);
CREATE INDEX IX_seg_usuarios_seguidor   ON dbo.seguimiento_usuarios(usuario_id);
CREATE INDEX IX_recordatorios_when      ON dbo.recordatorios(recordar_en);
GO

/* ===================== 6) Procedimientos Almacenados (tipos ajustados) ===================== */

-- Establecer/cambiar contraseña
CREATE OR ALTER PROCEDURE dbo.sp_usuario_set_password_simple
  @usuario_id INT,
  @password   NVARCHAR(128)           
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.usuarios
     SET password_hash = HASHBYTES('SHA2_512', CONVERT(VARBINARY(4000), @password))
   WHERE id = @usuario_id;
  IF @@ROWCOUNT = 0
    RAISERROR('Usuario no encontrado.', 16, 1);
END
GO

-- Verificar credenciales
CREATE OR ALTER PROCEDURE dbo.sp_usuario_login_simple
  @correo   VARCHAR(254),
  @password NVARCHAR(128)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @hash VARBINARY(64) = HASHBYTES('SHA2_512', CONVERT(VARBINARY(4000), @password));
  SELECT ok = CAST(IIF(EXISTS(
      SELECT 1 
      FROM dbo.usuarios 
      WHERE correo = @correo AND password_hash = @hash
  ), 1, 0) AS BIT);
END
GO