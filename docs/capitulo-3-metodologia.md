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
  
  // =========================================================
// Tribuneros - Schema para dbdiagram.io
// =========================================================

Table usuarios {
  id char(36) [pk, not null]
  correo varchar(255) [not null, unique]
  creado_en datetime2 [not null]
  
  indexes {
    correo [unique, name: "UQ_usuarios_correo"]
  }
}

Table perfiles {
  usuario_id char(36) [pk, not null, ref: - usuarios.id]
  nombre_usuario varchar(30) [not null, unique]
  nombre_mostrar varchar(60)
  avatar_url varchar(400)
  biografia varchar(400)
  creado_en datetime2 [not null]
  actualizado_en datetime2
  
  indexes {
    nombre_usuario [unique, name: "UQ_perfiles_usuario"]
  }
}

Table ligas {
  id int [pk, not null]
  nombre varchar(120) [not null]
  pais varchar(80)
  slug varchar(120) [unique]
  id_externo varchar(80)
  creado_en datetime2 [not null]
  
  indexes {
    slug [unique, name: "UQ_ligas_slug"]
  }
}

Table equipos {
  id int [pk, not null]
  nombre varchar(120) [not null]
  nombre_corto varchar(50)
  pais varchar(80)
  escudo_url varchar(400)
  liga_id int [ref: > ligas.id]
  id_externo varchar(80)
  creado_en datetime2 [not null]
}

Table partidos {
  id int [pk, not null]
  id_externo varchar(80)
  liga_id int [ref: > ligas.id]
  temporada int
  ronda varchar(40)
  fecha_utc datetime2 [not null]
  estado varchar(15) [not null, note: 'programado, en_vivo, finalizado, pospuesto, cancelado']
  estadio varchar(120)
  equipo_local int [not null, ref: > equipos.id]
  equipo_visitante int [not null, ref: > equipos.id]
  goles_local int
  goles_visitante int
  creado_en datetime2 [not null]
  
  indexes {
    fecha_utc [name: "IX_partidos_fecha"]
    liga_id [name: "IX_partidos_liga"]
  }
}

Table calificaciones {
  id int [pk, not null]
  partido_id int [not null, ref: > partidos.id]
  usuario_id char(36) [not null, ref: > usuarios.id]
  puntaje smallint [not null, note: '1-5']
  creado_en datetime2 [not null]
  
  indexes {
    (partido_id, usuario_id) [unique, name: "UQ_calif"]
    usuario_id [name: "IX_calif_usuario"]
  }
}

Table opiniones {
  id int [pk, not null]
  partido_id int [not null, ref: > partidos.id]
  usuario_id char(36) [not null, ref: > usuarios.id]
  titulo varchar(120)
  cuerpo varchar(4000)
  publica smallint [not null, note: '1=pública, 0=privada']
  tiene_spoilers smallint [not null, note: '1=sí, 0=no']
  creado_en datetime2 [not null]
  actualizado_en datetime2
  
  indexes {
    (partido_id, usuario_id) [unique, name: "UQ_opiniones"]
    usuario_id [name: "IX_opiniones_usuario"]
  }
}

Table favoritos {
  id int [pk, not null]
  partido_id int [not null, ref: > partidos.id]
  usuario_id char(36) [not null, ref: > usuarios.id]
  creado_en datetime2 [not null]
  
  indexes {
    (partido_id, usuario_id) [unique, name: "UQ_favoritos"]
    usuario_id [name: "IX_fav_usuario"]
  }
}

Table visualizaciones {
  id int [pk, not null]
  partido_id int [not null, ref: > partidos.id]
  usuario_id char(36) [not null, ref: > usuarios.id]
  medio varchar(12) [not null, note: 'estadio, tv, streaming, repeticion']
  visto_en datetime2 [not null]
  minutos_vistos int [note: '0-200']
  ubicacion varchar(120)
  creado_en datetime2 [not null]
  
  indexes {
    usuario_id [name: "IX_vis_usuario"]
  }
}

Table seguimiento_equipos {
  id int [pk, not null]
  usuario_id char(36) [not null, ref: > usuarios.id]
  equipo_id int [not null, ref: > equipos.id]
  creado_en datetime2 [not null]
  
  indexes {
    (usuario_id, equipo_id) [unique, name: "UQ_seguimiento_equipos"]
    usuario_id [name: "IX_seg_equipos_usuario"]
  }
}

Table seguimiento_ligas {
  id int [pk, not null]
  usuario_id char(36) [not null, ref: > usuarios.id]
  liga_id int [not null, ref: > ligas.id]
  creado_en datetime2 [not null]
  
  indexes {
    (usuario_id, liga_id) [unique, name: "UQ_seguimiento_ligas"]
    usuario_id [name: "IX_seg_ligas_usuario"]
  }
}

Table seguimiento_usuarios {
  id int [pk, not null]
  usuario_id char(36) [not null, ref: > usuarios.id]
  usuario_seguido char(36) [not null, ref: > usuarios.id]
  creado_en datetime2 [not null]
  
  indexes {
    (usuario_id, usuario_seguido) [unique, name: "UQ_seguimiento_usuarios"]
    usuario_id [name: "IX_seg_usuarios_seguidor"]
  }
}

Table partidos_destacados {
  id int [pk, not null]
  usuario_id char(36) [ref: > usuarios.id]
  partido_id int [not null, ref: > partidos.id]
  destacado_en date [not null]
  nota varchar(240)
}

Table recordatorios {
  id int [pk, not null]
  usuario_id char(36) [not null, ref: > usuarios.id]
  partido_id int [not null, ref: > partidos.id]
  recordar_en datetime2 [not null]
  estado varchar(12) [not null, note: 'pendiente, enviado, cancelado']
  creado_en datetime2 [not null]
  
  indexes {
    recordar_en [name: "IX_recordatorios_when"]
  }
}

```

</details>

Entidades principales:
- **Usuarios** (`usuarios`, `perfiles`)
- **Catálogos** (`ligas`, `equipos`)
- **Partidos** (`partidos`)
- **Interacciones** (`calificaciones`, `opiniones`, `favoritos`, `visualizaciones`)
- **Social** (`seguimiento_equipos`, `seguimiento_ligas`, `seguimiento_usuarios`)
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
