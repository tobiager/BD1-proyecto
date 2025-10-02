# Capítulo III — Metodología

## Diseño metodológico
El trabajo adopta un enfoque **iterativo-incremental**. Cada iteración combina análisis del dominio, diseño conceptual y verificación técnica. Las actividades se organizaron en sprints cortos que produjeron artefactos verificables (diagramas, scripts SQL y documentación). Este enfoque facilita recibir retroalimentación temprana y ajustar el modelo antes de comprometer la implementación definitiva.

Se parte de los requisitos funcionales definidos en el [Capítulo I](capitulo-1-introduccion.md#definición-del-problema) y las definiciones operativas del [Capítulo II](capitulo-2-marco-conceptual.md). El resultado esperado es un repositorio reproducible que permita a la cátedra evaluar decisiones de diseño y calidad de datos.

## Proceso de modelado
1. **Levantamiento del dominio**: identificación de entidades núcleo (usuarios, partidos, equipos) y eventos de interacción. Se elaboró un glosario compartido para evitar ambigüedades terminológicas.
2. **Modelado conceptual**: construcción del diagrama entidad-relación (ver `assets/der-tribuneros.png`) priorizando claridad de relaciones cardinales y atributos clave.
3. **Normalización**: revisión de dependencias funcionales y aplicación de 3FN para minimizar redundancias.
4. **Modelado lógico**: traducción del modelo conceptual a tablas, claves primarias/foráneas, restricciones y valores predeterminados.
5. **Validación cruzada**: contraste del modelo con casos de uso narrativos y con la carga de datos de prueba para detectar huecos.

## Estrategia de implementación
- **Definición del esquema**: el script [`script/creacion.sql`](../script/creacion.sql) crea la base `tribuneros_bdi`, define tablas y restricciones y aplica índices de apoyo.
- **Poblado inicial**: [`script/carga_inicial.sql`](../script/carga_inicial.sql) inserta un conjunto representativo de ligas, equipos, partidos y actividades de usuarios para ejercitar las restricciones.
- **Validaciones**: [`script/verificacion.sql`](../script/verificacion.sql) incluye consultas de consistencia y verificaciones funcionales; [`script/conteo.sql`](../script/conteo.sql) provee métricas rápidas para auditoría.
- **Orden de ejecución**: se recomienda el flujo indicado en el [README](../README.md#cómo-ejecutar-los-scripts) utilizando `:r` desde SQL Server Management Studio o `sqlcmd`.

## Herramientas y control de calidad
- **Gestión de versiones**: GitHub para trazabilidad y revisión de cambios.
- **SQL Server**: motor objetivo, probado localmente con SQL Server 2019.
- **Documentación colaborativa**: Markdown para capítulos y diccionario de datos, siguiendo el orden propuesto en [`docs/indice.md`](indice.md).
- **Revisión**: controles manuales tras cada iteración y verificación automática mediante las consultas incluidas en los scripts de validación.




## Esquema relacional  

![DER](/assets/der-tribuneros.png)  

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

|  Anterior | Siguiente  |
| --- | --- |
| [Capítulo II — Marco conceptual](capitulo-2-marco-conceptual.md) | [Capítulo IV — Resultados](capitulo-4-resultados.md) |
