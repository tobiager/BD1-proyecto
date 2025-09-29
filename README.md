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
2. [Capítulo IV — Desarrollo del tema / Resultados](#capítulo-iv--desarrollo-del-tema--resultados)
   - [Esquema relacional](#esquema-relacional)
   - [Script de creación (DDL)](#script-de-creación-ddl)
   - [Carga representativa (DML)](#carga-representativa-dml)
   - [Diccionario de datos](#diccionario-de-datos)
3. [Estructura del repositorio](#estructura-del-repo)
4. [Cómo ejecutar los scripts](#cómo-ejecutar-los-scripts)
   - [Requisitos previos](#requisitos-previos)
   - [Ejecución en SQL Server Management Studio](#ejecución-en-sql-server-management-studio)
   - [Ejecución con sqlcmd (Linux/macOS/WSL)](#ejecución-con-sqlcmd-linuxmacoswsl)
   - [Verificación de la carga](#verificación-de-la-carga)
5. [Licencia](#licencia)

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

## CAPÍTULO IV — DESARROLLO DEL TEMA / RESULTADOS  

### Esquema relacional  
![DER](./assets/der-tribuneros.png)  

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

> El **diccionario completo** se encuentra en el documento PDF (carpeta `docs/`).  

---

## Estructura del repo
```txt
.
├─ assets/
│  ├─ banner-bdi.jpg           # Identidad visual para presentaciones
│  ├─ der-tribuneros.png       # Diagrama entidad-relación
│  └─ badge-bdi.png            # Insignia para documentación
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
