<div align="center">
  
  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Cátedra-Bases%20de%20Datos%20I-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/badge/Entrega-Fase%201-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/badge/Motor-SQL%20Server-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/github/license/tobiager/BD1-proyecto?style=for-the-badge&labelColor=0a0a0a&color=008CFF" alt="License"/>
  </p>

</div>

# BD1 — Proyecto de Estudio e Investigación  

**Tribuneros**: red social del fútbol para **registrar, puntuar y comentar** partidos.  
Este repositorio contiene la documentación y scripts SQL Server correspondientes al **trabajo práctico integrador de Bases de Datos I (FaCENA–UNNE)**.

---

## Índice
1. [Capítulo I — Introducción](#capítulo-i--introducción)
   - [Tema](#tema)
   - [Definición o planteamiento del problema](#definición-o-planteamiento-del-problema)
   - [Objetivos del trabajo práctico](#objetivos-del-trabajo-práctico)
2. [Capítulo II — Marco conceptual o referencial](#capítulo-ii--marco-conceptual-o-referencial)
   - [2.1. Enfoque y delimitación del problema](#21-enfoque-y-delimitación-del-problema)
   - [2.2. Conceptos clave](#22-conceptos-clave)
4. [Capítulo IV — Desarrollo del tema / Resultados](#capítulo-iv--desarrollo-del-tema--resultados)
   - [Esquema relacional](#esquema-relacional)
   - [Script de creación (DDL)](#script-de-creación-ddl)
   - [Carga representativa (DML)](#carga-representativa-dml)
   - [Diccionario de datos](#diccionario-de-datos)
1. [Estructura del repositorio](#estructura-del-repo)
2. [Cómo ejecutar los scripts](#cómo-ejecutar-los-scripts)
   - [Requisitos previos](#requisitos-previos)
   - [Ejecución en SQL Server Management Studio](#ejecución-en-sql-server-management-studio)
   - [Verificación de la carga](#verificación-de-la-carga)
3. [Licencia](#licencia)

---

## CAPÍTULO I — INTRODUCCIÓN  

### Tema  
**Tribuneros – Red social del fútbol para registrar, puntuar y comentar partidos.**  
El proyecto plantea el diseño e implementación de un **modelo de datos relacional** que soporte una aplicación social destinada a los aficionados al fútbol.  

### Definición o planteamiento del problema  
Los aficionados no cuentan con una herramienta unificada que les permita:  
- Registrar los partidos que vieron, con fecha, marcador y medio de visualización.  
- Calificar y escribir opiniones, con opciones de privacidad y control de spoilers.  
- Marcar favoritos, seguir equipos de interés y programar recordatorios.  
- Consultar partidos destacados seleccionados por curaduría.  

Hoy esa información se encuentra dispersa en apps de resultados, redes sociales y notas personales. Esto genera **pérdida de registros**, menor participación y falta de estadísticas personalizadas.  

### Objetivos del trabajo práctico  

**Objetivo general**  
Diseñar y documentar un modelo de datos relacional para Tribuneros, asegurando integridad, consistencia y escalabilidad.  

**Objetivos específicos**  
- Definir entidades, relaciones y restricciones de integridad.  
- Elaborar un esquema relacional normalizado.  
- Implementar el modelo en SQL Server con **scripts DDL/DML**.  
- Documentar diccionario de datos y justificación de diseño.  
- Versionar en GitHub para trazabilidad y reproducibilidad.  

---

## Capítulo II — Marco conceptual o referencial

> Versión completa en [`docs/capitulo-2-marco-conceptual.md`](docs/capitulo-2-marco-conceptual.md)

### 2.1. Enfoque y delimitación del problema
- **Tema**: registro social de experiencias de visionado de fútbol y producción de reseñas/calificaciones con control de *spoilers*.
- **Objeto de estudio**: las **interacciones** entre usuarios, partidos y contenido (visualizaciones, calificaciones, opiniones, favoritos, seguimientos, recordatorios y curaduría de destacados).
- **Unidades de análisis**: usuario, partido y publicación (opinión/calificación).
- **Ámbito**: ligas y equipos profesionales (extensible a selecciones y copas); foco en consumo pos-partido y conversación segura (sin *spoilers*).
- **Propósito del marco**: estandarizar términos y supuestos para el modelo de datos y los indicadores de engagement/actividad que se reportarán en los capítulos siguientes.

### 2.2. Conceptos clave
1. **Plataforma social**  
   *Definición operativa*: sistema multiusuario con perfiles, publicaciones y vínculos (seguir equipos, marcar favoritos).  
   *Rol*: infraestructura sociotécnica que habilita interacción y efecto red.

2. **Contenido generado por usuarios (UGC)**  
   *Definición operativa*: opiniones y calificaciones creadas por personas usuarias sobre partidos.  
   *Rol*: insumo central para reputación, descubrimiento y curaduría.

3. **Experiencia de visualización**  
   *Definición operativa*: acto de ver un partido con metadatos de medio y duración (`minutes_watched`, `viewed_at`).  
   *Rol*: puerta de entrada para calificar y opinar; base de métricas de consumo.

4. **Calificación (rating)**  
   *Definición operativa*: valoración numérica discreta del partido (p. ej., 1–5).  
   *Rol*: insumo cuantitativo para promedios, rankings y recomendaciones básicas.

5. **Opinión / Reseña**  
   *Definición operativa*: publicación textual con banderas de visibilidad (`is_public`) y *spoilers* (`has_spoilers`).  
   *Rol*: canal cualitativo de discusión y memoria del partido.

6. **Spoilers**  
   *Definición operativa*: revelación de eventos clave; se marca explícitamente.  
   *Rol*: **protege la experiencia**; condiciona la visibilidad en el feed.

7. **Privacidad**  
   *Definición operativa*: ámbito de publicación (público/privado) configurable por el autor.  
   *Rol*: determina alcance del contenido y cumplimiento normativo.

8. **Seguimiento y favoritos**  
   *Definición operativa*: seguir equipos de interés y marcar partidos como favoritos.  
   *Rol*: personaliza el feed y las notificaciones.

9. **Curaduría / Partidos destacados**  
   *Definición operativa*: selección editorial o algorítmica de partidos a resaltar (`featured_on`, `curated_by`).  
   *Rol*: aumenta descubrimiento y concentra la conversación.

10. **Recordatorios**  
    *Definición operativa*: alertas programadas asociadas a un partido (`remind_at`, `status`).  
    *Rol*: impulsa intención de visualización y cierre del ciclo ver → calificar → opinar.

11. **Reputación y confianza**  
    *Definición operativa*: señales derivadas de actividad (antigüedad, consistencia, proporción de contenido público).  
    *Rol*: prioriza contenido de calidad y reduce ruido.

12. **Integridad e interoperabilidad de datos**  
    *Definición operativa*: claves foráneas, catálogos (ligas, equipos, estados) y restricciones que aseguran consistencia.  
    *Rol*: base de reportes confiables y evolución del modelo.

---

## CAPÍTULO IV — DESARROLLO DEL TEMA / RESULTADOS  

### Esquema relacional  
![DER](./assets/der-tribuneros.png)  

<details>
  <summary><b> Script DBdiagram.io</b></summary>
  
  ```
  
  Table usuarios {
  id UNIQUEIDENTIFIER [pk]
  correo varchar [unique, not null]
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
}

Table perfiles {
  usuario_id UNIQUEIDENTIFIER [pk]
  nombre_usuario varchar [unique, not null]
  nombre_mostrar varchar
  avatar_url varchar
  biografia varchar
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
  actualizado_en timestamp
}

Table ligas {
  id int [pk]
  nombre varchar [not null]
  pais varchar
  slug varchar [unique]
  id_externo varchar
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
}

Table equipos {
  id int [pk]
  nombre varchar [not null]
  nombre_corto varchar
  pais varchar
  escudo_url varchar
  liga_id int
  id_externo varchar
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
}

Table partidos {
  id int [pk]
  id_externo varchar
  liga_id int
  temporada int
  ronda varchar
  fecha_utc timestamp [not null]
  estado varchar [not null]
  estadio varchar
  equipo_local int [not null]
  equipo_visitante int [not null]
  goles_local int
  goles_visitante int
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
}

Table calificaciones {
  id int [pk]
  partido_id int [not null]
  usuario_id UNIQUEIDENTIFIER [not null]
  puntaje int [not null]
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']

  indexes {
    (partido_id, usuario_id) [unique]
  }
}

Table opiniones {
  id int [pk]
  partido_id int [not null]
  usuario_id UNIQUEIDENTIFIER [not null]
  titulo varchar
  cuerpo varchar
  publica BIT [not null, default: '(1)']
  tiene_spoilers BIT [not null, default: '(0)']
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
  actualizado_en timestamp

  indexes {
    (partido_id, usuario_id) [unique]
  }
}

Table favoritos {
  id int [pk]
  partido_id int [not null]
  usuario_id UNIQUEIDENTIFIER [not null]
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']

  indexes {
    (partido_id, usuario_id) [unique]
  }
}

Table visualizaciones {
  id int [pk]
  partido_id int [not null]
  usuario_id UNIQUEIDENTIFIER [not null]
  medio varchar [not null]
  visto_en timestamp [not null]
  minutos_vistos int
  ubicacion varchar
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']
}

Table seguidos {
  id int [pk]
  usuario_id UNIQUEIDENTIFIER [not null]
  equipo_id int [not null]
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']

  indexes {
    (usuario_id, equipo_id) [unique]
  }
}

Table partidos_destacados {
  id int [pk]
  usuario_id UNIQUEIDENTIFIER
  partido_id int [not null]
  destacado_en DATE [not null]
  nota varchar

  indexes {
    (partido_id) [unique]
  }
}

Table recordatorios {
  id int [pk]
  usuario_id UNIQUEIDENTIFIER [not null]
  partido_id int [not null]
  recordar_en timestamp [not null]
  estado varchar [not null]
  creado_en timestamp [not null, default: 'SYSUTCDATETIME()']

  indexes {
    (usuario_id, partido_id, recordar_en) [unique]
  }
}

/* Relaciones */
Ref: perfiles.usuario_id > usuarios.id
Ref: equipos.liga_id > ligas.id
Ref: partidos.liga_id > ligas.id
Ref: partidos.equipo_local > equipos.id
Ref: partidos.equipo_visitante > equipos.id
Ref: calificaciones.partido_id > partidos.id
Ref: calificaciones.usuario_id > usuarios.id
Ref: opiniones.partido_id > partidos.id
Ref: opiniones.usuario_id > usuarios.id
Ref: favoritos.partido_id > partidos.id
Ref: favoritos.usuario_id > usuarios.id
Ref: visualizaciones.partido_id > partidos.id
Ref: visualizaciones.usuario_id > usuarios.id
Ref: seguidos.usuario_id > usuarios.id
Ref: seguidos.equipo_id > equipos.id
Ref: partidos_destacados.partido_id > partidos.id
Ref: partidos_destacados.usuario_id > usuarios.id
Ref: recordatorios.usuario_id > usuarios.id
Ref: recordatorios.partido_id > partidos.id

```

</details>

Entidades principales:
- **Usuarios** (`usuarios`, `perfiles`)
- **Catálogos** (`ligas`, `equipos`)
- **Partidos** (`partidos`)
- **Interacciones** (`calificaciones`, `opiniones`, `favoritos`, `visualizaciones`)
- **Social** (`seguidos`)
- **Curaduría y extras** (`partidos_destacados`, `recordatorios`)
**Highlights de diseño**
- PK/FK y **UNIQUE** en combinaciones clave (`partido_id,usuario_id`).
- **CHECK** para estados (`partidos.estado`, `visualizaciones.medio`, `recordatorios.estado`).
- `ON DELETE CASCADE` en relaciones de usuario; `RESTRICT/SET NULL` en catálogos.
- Índices por `partidos.fecha_utc`, `partidos.liga_id` y `usuario_id` en tablas de interacciones para consultas frecuentes.

---

### Script de creación (DDL)  
📂 [`script/creacion.sql`](./script/creacion.sql)  

Incluye:  
- Tablas con claves primarias y foráneas.  
- Restricciones `NOT NULL`, `UNIQUE`, `CHECK`.  
- Índices de apoyo para rendimiento.  

Ejemplo:  

```sql
CREATE TABLE dbo.calificaciones (
  id         BIGINT IDENTITY(1,1) CONSTRAINT PK_calificaciones PRIMARY KEY,
  partido_id BIGINT           NOT NULL CONSTRAINT FK_calif_partido REFERENCES dbo.partidos(id) ON DELETE CASCADE,
  usuario_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_calif_usuario REFERENCES dbo.usuarios(id) ON DELETE CASCADE,
  puntaje    TINYINT          NOT NULL CONSTRAINT CK_calif_1_5 CHECK (puntaje BETWEEN 1 AND 5),
  creado_en  DATETIME2        NOT NULL CONSTRAINT DF_calif_creado DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_calif UNIQUE (partido_id, usuario_id)
);
```  

---

### Carga representativa (DML)  
📂 [`script/carga_inicial.sql`](./script/carga_inicial.sql)  

Incluye:  
- 2 usuarios de prueba.  
- Ligas: Primera División Argentina y Copa Libertadores.  
- Equipos: River Plate, Boca Juniors, Fluminense.  
- Partido cargado: River vs Boca (Clásico).  
- Datos de interacción: rating, opinión, favorito, recordatorio.  

---

### Diccionario de datos

| Tabla | Columna | Tipo | Regla | Descripción |
|---|---|---|---|---|
| `usuarios` | `id` | UNIQUEIDENTIFIER | PK, `DEFAULT NEWID()` | Identificador del usuario |
| `usuarios` | `correo` | NVARCHAR(255) | UNIQUE, NOT NULL | Correo de acceso |
| `perfiles` | `nombre_usuario` | NVARCHAR(30) | UNIQUE, NOT NULL | Alias público |
| `partidos` | `estado` | NVARCHAR(15) | CHECK estados válidos | Estado del partido |
| `calificaciones` | `puntaje` | TINYINT | CHECK 1–5 | Puntuación del partido |
| `visualizaciones` | `medio` | NVARCHAR(12) | CHECK valores válidos | Medio de visualización |
| `seguidos` | `(usuario_id,equipo_id)` | — | UNIQUE | Un usuario sigue un equipo una sola vez |
| `recordatorios` | `estado` | NVARCHAR(12) | CHECK valores válidos | Estado del recordatorio |

> Consulta el [diccionario de datos completo](docs/diccionario_datos.md) para obtener el detalle por tabla, columnas y reglas de negocio.

---

## Estructura del repo
```txt
.
├─ assets/
│  ├─ banner-bdi.jpg           # Identidad visual para presentaciones
│  ├─ der-tribuneros.png       # Diagrama entidad-relación
│  └─ badge-bdi.png            # Insignia para documentación
├─ docs/
│  ├─ capitulo-2-marco-conceptual.md # Versión extendida del marco conceptual
│  └─ diccionario_datos.md           # Diccionario de datos completo en formato Markdown
├─ script/
│  ├─ creacion.sql             # DDL: tablas, claves y restricciones
│  ├─ carga_inicial.sql        # DML: dataset representativo
│  ├─ verificacion.sql         # Consultas de control y consistencia
│  └─ conteo.sql               # Métricas rápidas de carga
├─ README.md                   # Este documento
└─ LICENSE
```

---

## Cómo ejecutar los scripts

### Requisitos previos
- SQL Server 2019+ (on-premise, Docker o Azure SQL Database).
- Un cliente para ejecutar scripts T-SQL: **SQL Server Management Studio (SSMS 19/20)**, **Azure Data Studio** o la utilidad de línea de comandos **sqlcmd**.
- Clonar este repositorio o descargarlo como ZIP para tener disponibles los archivos `.sql`.

### Ejecución en SQL Server Management Studio
1. Crear una base de datos vacía (`Tribuneros` recomendado).
2. Abrir una nueva ventana de consulta apuntando a la base.
3. Ejecutar, en este orden, los scripts de creación y carga utilizando la directiva `:r`:

   ```sql
   :r .\script\creacion.sql
   GO
   :r .\script\carga_inicial.sql
   GO
   ```

4. Validar rápidamente con consultas sugeridas (pueden copiarse desde `script/verificacion.sql`).

### Verificación de la carga
- Ejecutar `script/verificacion.sql` para revisar que las tablas principales tengan registros y relaciones consistentes.
- Ejecutar `script/conteo.sql` para obtener un resumen de cantidades por entidad.
- Consultas útiles (ver `script/verificacion.sql` para más ejemplos):

  ```sql
  SELECT p.fecha_utc,
         e_local.nombre      AS equipo_local,
         e_visitante.nombre  AS equipo_visitante
  FROM dbo.partidos AS p
  JOIN dbo.equipos  AS e_local
    ON e_local.id = p.equipo_local
  JOIN dbo.equipos  AS e_visitante
    ON e_visitante.id = p.equipo_visitante;
  ```

---

## Licencia
- **Código SQL**: MIT  
- **Documento académico**: CC BY-NC-SA 4.0  

<div align="center">
  <br/>
  <img src="./assets/badge-bdi.png" alt="BDI Badge" height="120"/><br/>
  <sub>❤️🐔 Hecho con pasión y dedicación — FaCENA · UNNE</sub>
</div>
