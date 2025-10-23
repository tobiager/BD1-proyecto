
-- =========================================================
-- Tribuneros - Esquema SQL Server (Primera Entrega BDI) 
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
  id         CHAR(36)      NOT NULL,
  correo     VARCHAR(255)  NOT NULL,
  password_hash VARBINARY(64) NULL, -- Hash de la contraseña (SHA2_512)
  creado_en  DATETIME2     NOT NULL,
  CONSTRAINT PK_usuarios PRIMARY KEY (id),
  CONSTRAINT UQ_usuarios_correo UNIQUE (correo)
);

CREATE TABLE dbo.perfiles (
  usuario_id     CHAR(36)     NOT NULL,
  nombre_usuario VARCHAR(30)  NOT NULL,
  nombre_mostrar VARCHAR(60)  NULL,
  avatar_url     VARCHAR(400) NULL,
  biografia      VARCHAR(400) NULL,
  creado_en      DATETIME2    NOT NULL,
  actualizado_en DATETIME2    NULL,
  CONSTRAINT PK_perfiles PRIMARY KEY (usuario_id),
  CONSTRAINT UQ_perfiles_usuario UNIQUE (nombre_usuario),
  CONSTRAINT FK_perfiles_usuario
    FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);
GO

/* ===================== 2) Catálogos ===================== */
CREATE TABLE dbo.ligas (
  id         INT           NOT NULL,
  nombre     VARCHAR(120)  NOT NULL,
  pais       VARCHAR(80)   NULL,
  slug       VARCHAR(120)  NULL,
  id_externo VARCHAR(80)   NULL,
  creado_en  DATETIME2     NOT NULL,
  CONSTRAINT PK_ligas PRIMARY KEY (id),
  CONSTRAINT UQ_ligas_slug UNIQUE (slug)
);

CREATE TABLE dbo.equipos (
  id           INT           NOT NULL,
  nombre       VARCHAR(120)  NOT NULL,
  nombre_corto VARCHAR(50)   NULL,
  pais         VARCHAR(80)   NULL,
  escudo_url   VARCHAR(400)  NULL,
  liga_id      INT           NULL,
  id_externo   VARCHAR(80)   NULL,
  creado_en    DATETIME2     NOT NULL,
  CONSTRAINT PK_equipos PRIMARY KEY (id),
  CONSTRAINT FK_equipos_liga FOREIGN KEY (liga_id)
    REFERENCES dbo.ligas(id) ON DELETE SET NULL
);
GO

/* ===================== 3) Partidos ===================== */
CREATE TABLE dbo.partidos (
  id               INT           NOT NULL,
  id_externo       VARCHAR(80)   NULL,
  liga_id          INT           NULL,
  temporada        INT           NULL,
  ronda            VARCHAR(40)   NULL,
  fecha_utc        DATETIME2     NOT NULL,
  estado           VARCHAR(15)   NOT NULL,
  estadio          VARCHAR(120)  NULL,
  equipo_local     INT           NOT NULL,
  equipo_visitante INT           NOT NULL,
  goles_local      INT           NULL,
  goles_visitante  INT           NULL,
  creado_en        DATETIME2     NOT NULL,
  CONSTRAINT PK_partidos PRIMARY KEY (id),
  CONSTRAINT CK_partidos_estado CHECK (estado IN ('programado','en_vivo','finalizado','pospuesto','cancelado')),
  CONSTRAINT CK_partidos_equipos_distintos CHECK (equipo_local <> equipo_visitante),
  CONSTRAINT FK_partidos_liga        FOREIGN KEY (liga_id)         REFERENCES dbo.ligas(id) ON DELETE SET NULL,
  CONSTRAINT FK_partidos_local       FOREIGN KEY (equipo_local)    REFERENCES dbo.equipos(id),
  CONSTRAINT FK_partidos_visitante   FOREIGN KEY (equipo_visitante)REFERENCES dbo.equipos(id)
);

CREATE INDEX IX_partidos_fecha ON dbo.partidos(fecha_utc);
CREATE INDEX IX_partidos_liga  ON dbo.partidos(liga_id);
GO

/* ===================== 4) Interacciones ===================== */
CREATE TABLE dbo.calificaciones (
  id         INT         NOT NULL,
  partido_id INT         NOT NULL,
  usuario_id CHAR(36)    NOT NULL,
  puntaje    SMALLINT    NOT NULL,
  creado_en  DATETIME2   NOT NULL,
  CONSTRAINT PK_calificaciones PRIMARY KEY (id),
  CONSTRAINT CK_calif_1_5 CHECK (puntaje BETWEEN 1 AND 5),
  CONSTRAINT UQ_calif UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_calif_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_calif_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.opiniones (
  id             INT           NOT NULL,
  partido_id     INT           NOT NULL,
  usuario_id     CHAR(36)      NOT NULL,
  titulo         VARCHAR(120)  NULL,
  cuerpo         VARCHAR(4000) NULL,
  publica        SMALLINT      NOT NULL,  -- 1 = pública, 0 = privada
  tiene_spoilers SMALLINT      NOT NULL,  -- 1 = sí, 0 = no
  creado_en      DATETIME2     NOT NULL,
  actualizado_en DATETIME2     NULL,
  CONSTRAINT PK_opiniones PRIMARY KEY (id),
  CONSTRAINT CK_opiniones_publica  CHECK (publica IN (0,1)),
  CONSTRAINT CK_opiniones_spoilers CHECK (tiene_spoilers IN (0,1)),
  CONSTRAINT UQ_opiniones UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_opiniones_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_opiniones_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.favoritos (
  id         INT        NOT NULL,
  partido_id INT        NOT NULL,
  usuario_id CHAR(36)   NOT NULL,
  creado_en  DATETIME2  NOT NULL,
  CONSTRAINT PK_favoritos PRIMARY KEY (id),
  CONSTRAINT UQ_favoritos UNIQUE (partido_id, usuario_id),
  CONSTRAINT FK_fav_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_fav_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);

CREATE TABLE dbo.visualizaciones (
  id             INT           NOT NULL,
  partido_id     INT           NOT NULL,
  usuario_id     CHAR(36)      NOT NULL,
  medio          VARCHAR(12)   NOT NULL, -- 'estadio' | 'tv' | 'streaming' | 'repeticion'
  visto_en       DATETIME2     NOT NULL,
  minutos_vistos INT           NULL,
  ubicacion      VARCHAR(120)  NULL,
  creado_en      DATETIME2     NOT NULL,
  CONSTRAINT PK_visualizaciones PRIMARY KEY (id),
  CONSTRAINT CK_vis_medio   CHECK (medio IN ('estadio','tv','streaming','repeticion')),
  CONSTRAINT CK_vis_minutos CHECK (minutos_vistos IS NULL OR minutos_vistos BETWEEN 0 AND 200),
  CONSTRAINT FK_vis_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  CONSTRAINT FK_vis_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE
);
GO

/* ===================== 5) Social / Curaduría / Recordatorios ===================== */
CREATE TABLE dbo.seguimiento_equipos (
  id         INT        NOT NULL,
  usuario_id CHAR(36)   NOT NULL,
  equipo_id  INT        NOT NULL,
  creado_en  DATETIME2  NOT NULL,
  CONSTRAINT PK_seguimiento_equipos PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_equipos UNIQUE (usuario_id, equipo_id),
  CONSTRAINT FK_seg_equipos_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_equipos_equipo FOREIGN KEY (equipo_id)  REFERENCES dbo.equipos(id)  ON DELETE CASCADE
);

CREATE TABLE dbo.seguimiento_ligas (
  id         INT        NOT NULL,
  usuario_id CHAR(36)   NOT NULL,
  liga_id    INT        NOT NULL,
  creado_en  DATETIME2  NOT NULL,
  CONSTRAINT PK_seguimiento_ligas PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_ligas UNIQUE (usuario_id, liga_id),
  CONSTRAINT FK_seg_ligas_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_ligas_liga FOREIGN KEY (liga_id)    REFERENCES dbo.ligas(id)    ON DELETE CASCADE
);

CREATE TABLE dbo.seguimiento_usuarios (
  id              INT        NOT NULL,
  usuario_id      CHAR(36)   NOT NULL, -- El que sigue
  usuario_seguido CHAR(36)   NOT NULL, -- El seguido
  creado_en       DATETIME2  NOT NULL,
  CONSTRAINT PK_seguimiento_usuarios PRIMARY KEY (id),
  CONSTRAINT UQ_seguimiento_usuarios UNIQUE (usuario_id, usuario_seguido),
  CONSTRAINT CK_seg_usuarios_no_self CHECK (usuario_id <> usuario_seguido),
  CONSTRAINT FK_seg_usuarios_seguidor FOREIGN KEY (usuario_id) 
    REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_seg_usuarios_seguido FOREIGN KEY (usuario_seguido) 
    REFERENCES dbo.usuarios(id) ON DELETE NO ACTION
);

CREATE TABLE dbo.partidos_destacados (
  id           INT          NOT NULL,
  usuario_id   CHAR(36)     NULL,
  partido_id   INT          NOT NULL,
  destacado_en DATE         NOT NULL,
  nota         VARCHAR(240) NULL,
  CONSTRAINT PK_destacados PRIMARY KEY (id),
  CONSTRAINT FK_destacados_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE SET NULL,
  CONSTRAINT FK_destacados_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE
);

CREATE TABLE dbo.recordatorios (
  id          INT         NOT NULL,
  usuario_id  CHAR(36)    NOT NULL,
  partido_id  INT         NOT NULL,
  recordar_en DATETIME2   NOT NULL,
  estado      VARCHAR(12) NOT NULL, -- 'pendiente' | 'enviado' | 'cancelado'
  creado_en   DATETIME2   NOT NULL,
  CONSTRAINT PK_recordatorios PRIMARY KEY (id),
  CONSTRAINT CK_recordatorios_estado CHECK (estado IN ('pendiente','enviado','cancelado')),
  CONSTRAINT FK_recordatorios_usuario FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  CONSTRAINT FK_recordatorios_partido FOREIGN KEY (partido_id) REFERENCES dbo.partidos(id) ON DELETE CASCADE
);

-- Índices auxiliares (mismo estilo)
CREATE INDEX IX_calif_usuario      ON dbo.calificaciones(usuario_id);
CREATE INDEX IX_opiniones_usuario  ON dbo.opiniones(usuario_id);
CREATE INDEX IX_fav_usuario        ON dbo.favoritos(usuario_id);
CREATE INDEX IX_vis_usuario        ON dbo.visualizaciones(usuario_id);
CREATE INDEX IX_seg_equipos_usuario ON dbo.seguimiento_equipos(usuario_id);
CREATE INDEX IX_seg_ligas_usuario   ON dbo.seguimiento_ligas(usuario_id);
CREATE INDEX IX_seg_usuarios_seguidor ON dbo.seguimiento_usuarios(usuario_id);
CREATE INDEX IX_recordatorios_when ON dbo.recordatorios(recordar_en);
GO
