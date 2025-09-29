-- =========================================================
-- Tribuneros - Esquema SQL Server (Primera Entrega BDI) 
-- =========================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

-- Crear base de datos si no existe
IF DB_ID('tribuneros_bdi') IS NULL
BEGIN
  PRINT 'Creando base de datos tribuneros_bdi...';
  CREATE DATABASE tribuneros_bdi;
END
GO

USE tribuneros_bdi;
GO

-- Limpieza (solo en desarrollo)
IF OBJECT_ID('dbo.recordatorios') IS NOT NULL DROP TABLE dbo.recordatorios;
IF OBJECT_ID('dbo.partidos_destacados') IS NOT NULL DROP TABLE dbo.partidos_destacados;
IF OBJECT_ID('dbo.seguidos') IS NOT NULL DROP TABLE dbo.seguidos;
IF OBJECT_ID('dbo.visualizaciones') IS NOT NULL DROP TABLE dbo.visualizaciones;
IF OBJECT_ID('dbo.favoritos') IS NOT NULL DROP TABLE dbo.favoritos;
IF OBJECT_ID('dbo.opiniones') IS NOT NULL DROP TABLE dbo.opiniones;
IF OBJECT_ID('dbo.calificaciones') IS NOT NULL DROP TABLE dbo.calificaciones;
IF OBJECT_ID('dbo.partidos') IS NOT NULL DROP TABLE dbo.partidos;
IF OBJECT_ID('dbo.equipos') IS NOT NULL DROP TABLE dbo.equipos;
IF OBJECT_ID('dbo.ligas') IS NOT NULL DROP TABLE dbo.ligas;
IF OBJECT_ID('dbo.perfiles') IS NOT NULL DROP TABLE dbo.perfiles;
IF OBJECT_ID('dbo.usuarios') IS NOT NULL DROP TABLE dbo.usuarios;
GO

-- 1) Usuarios y perfiles
CREATE TABLE dbo.usuarios (
  id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_usuarios PRIMARY KEY,
  correo     NVARCHAR(255)    NOT NULL CONSTRAINT UQ_usuarios_correo UNIQUE,
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_usuarios_creado DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.perfiles (
  usuario_id   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_perfiles PRIMARY KEY  CONSTRAINT FK_perfiles_usuario  REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  nombre_usuario NVARCHAR(30)   NOT NULL CONSTRAINT UQ_perfiles_usuario UNIQUE,
  nombre_mostrar NVARCHAR(60)   NULL,
  avatar_url    NVARCHAR(400)   NULL,
  biografia     NVARCHAR(400)   NULL,
  creado_en     DATETIME2       NOT NULL CONSTRAINT DF_perfiles_creado DEFAULT SYSUTCDATETIME(),
  actualizado_en DATETIME2      NULL
);

-- 2) Catálogos
CREATE TABLE dbo.ligas (
  id          BIGINT IDENTITY(1,1) CONSTRAINT PK_ligas PRIMARY KEY,
  nombre      NVARCHAR(120) NOT NULL,
  pais        NVARCHAR(80)  NULL,
  slug        NVARCHAR(120) NULL CONSTRAINT UQ_ligas_slug UNIQUE,
  id_externo  NVARCHAR(80)  NULL,
  creado_en   DATETIME2     NOT NULL CONSTRAINT DF_ligas_creado DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.equipos (
  id          BIGINT IDENTITY(1,1) CONSTRAINT PK_equipos PRIMARY KEY,
  nombre      NVARCHAR(120) NOT NULL,
  nombre_corto NVARCHAR(50) NULL,
  pais        NVARCHAR(80)  NULL,
  escudo_url  NVARCHAR(400) NULL,
  liga_id     BIGINT        NULL CONSTRAINT FK_equipos_liga REFERENCES dbo.ligas(id) ON DELETE SET NULL,
  id_externo  NVARCHAR(80)  NULL,
  creado_en   DATETIME2     NOT NULL CONSTRAINT DF_equipos_creado DEFAULT SYSUTCDATETIME()
);

-- 3) Partidos
CREATE TABLE dbo.partidos (
  id            BIGINT IDENTITY(1,1) CONSTRAINT PK_partidos PRIMARY KEY,
  id_externo    NVARCHAR(80) NULL,
  liga_id       BIGINT       NULL CONSTRAINT FK_partidos_liga  REFERENCES dbo.ligas(id) ON DELETE SET NULL,
  temporada     INT          NULL,
  ronda         NVARCHAR(40) NULL,
  fecha_utc     DATETIME2    NOT NULL,
  estado        NVARCHAR(15) NOT NULL CONSTRAINT CK_partidos_estado CHECK (estado IN (N'programado',N'en_vivo',N'finalizado',N'pospuesto',N'cancelado')),
  estadio       NVARCHAR(120) NULL,
  equipo_local  BIGINT       NOT NULL,
  equipo_visitante BIGINT    NOT NULL,
  goles_local   INT          NULL,
  goles_visitante INT        NULL,
  creado_en     DATETIME2    NOT NULL CONSTRAINT DF_partidos_creado DEFAULT SYSUTCDATETIME(),
  CONSTRAINT CK_partidos_equipos_distintos CHECK (equipo_local <> equipo_visitante)
);

-- FKs explícitas
ALTER TABLE dbo.partidos WITH CHECK
  ADD CONSTRAINT FK_partidos_local FOREIGN KEY (equipo_local)
      REFERENCES dbo.equipos(id) ON DELETE NO ACTION;
ALTER TABLE dbo.partidos WITH CHECK
  ADD CONSTRAINT FK_partidos_visitante FOREIGN KEY (equipo_visitante)
      REFERENCES dbo.equipos(id) ON DELETE NO ACTION;

CREATE INDEX IX_partidos_fecha ON dbo.partidos(fecha_utc);
CREATE INDEX IX_partidos_liga ON dbo.partidos(liga_id);

-- 4) Interacciones
CREATE TABLE dbo.calificaciones (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_calificaciones PRIMARY KEY,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_calif_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_calif_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  puntaje    TINYINT          NOT NULL CONSTRAINT CK_calif_1_5 CHECK (puntaje BETWEEN 1 AND 5),
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_calif_creado DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_calif UNIQUE (partido_id, usuario_id)
);

CREATE TABLE dbo.opiniones (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_opiniones PRIMARY KEY,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_opiniones_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_opiniones_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  titulo     NVARCHAR(120)    NULL,
  cuerpo     NVARCHAR(MAX)    NULL,
  publica    BIT              NOT NULL CONSTRAINT DF_opiniones_publica DEFAULT (1),
  tiene_spoilers BIT          NOT NULL CONSTRAINT DF_opiniones_spoilers DEFAULT (0),
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_opiniones_creado DEFAULT SYSUTCDATETIME(),
  actualizado_en DATETIME2    NULL,
  CONSTRAINT UQ_opiniones UNIQUE (partido_id, usuario_id)
);

CREATE TABLE dbo.favoritos (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_favoritos PRIMARY KEY,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_fav_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_fav_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_fav_creado DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_fav UNIQUE (partido_id, usuario_id)
);

CREATE TABLE dbo.visualizaciones (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_visualizaciones PRIMARY KEY,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_vis_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_vis_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  medio      NVARCHAR(12)     NOT NULL CONSTRAINT CK_vis_medio CHECK (medio IN (N'estadio',N'tv',N'streaming',N'repetición')),
  visto_en   DATETIME2        NOT NULL,
  minutos_vistos INT          NULL CONSTRAINT CK_vis_minutos CHECK (minutos_vistos IS NULL OR minutos_vistos BETWEEN 0 AND 200),
  ubicacion  NVARCHAR(120)    NULL,
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_vis_creado DEFAULT SYSUTCDATETIME()
);

-- 5) Social / Curaduría / Recordatorios
CREATE TABLE dbo.seguidos (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_seguidos PRIMARY KEY,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_seguidos_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  equipo_id  BIGINT           NOT NULL CONSTRAINT FK_seguidos_equipo REFERENCES dbo.equipos(id) ON DELETE CASCADE,
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_seguidos_creado DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_seguidos UNIQUE (usuario_id, equipo_id)
);

CREATE TABLE dbo.partidos_destacados (
  id           BIGINT IDENTITY(1,1) CONSTRAINT PK_destacados PRIMARY KEY,
  usuario_id   UNIQUEIDENTIFIER NULL CONSTRAINT FK_destacados_usuario REFERENCES dbo.usuarios(id) ON DELETE SET NULL,
  partido_id   BIGINT           NOT NULL CONSTRAINT FK_destacados_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  destacado_en DATE             NOT NULL,
  nota         NVARCHAR(240)    NULL
);

CREATE TABLE dbo.recordatorios (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_recordatorios PRIMARY KEY,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_recordatorios_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_recordatorios_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  recordar_en DATETIME2       NOT NULL,
  estado     NVARCHAR(12)     NOT NULL CONSTRAINT CK_recordatorios_estado CHECK (estado IN (N'pendiente', N'enviado', N'cancelado')),
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_recordatorios_creado DEFAULT SYSUTCDATETIME()
);

-- Índices
CREATE INDEX IX_calif_usuario    ON dbo.calificaciones(usuario_id);
CREATE INDEX IX_opiniones_usuario ON dbo.opiniones(usuario_id);
CREATE INDEX IX_fav_usuario      ON dbo.favoritos(usuario_id);
CREATE INDEX IX_vis_usuario      ON dbo.visualizaciones(usuario_id);
CREATE INDEX IX_seguidos_usuario ON dbo.seguidos(usuario_id);
CREATE INDEX IX_recordatorios    ON dbo.recordatorios(recordar_en);
GO

PRINT 'Esquema creado correctamente.';