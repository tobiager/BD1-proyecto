<div align="center">

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Cátedra-Bases%20de%20Datos%20I-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/badge/Entrega-Fase%201-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/badge/Motor- SQL%20Server-008CFF?style=for-the-badge&labelColor=0a0a0a"/>
    <img src="https://img.shields.io/github/license/tobiager/BD1-proyecto?style=for-the-badge&labelColor=0a0a0a&color=008CFF" alt="License"/>
  </p>

</div>

# BD1 — Proyecto de Estudio e Investigación

**Tribuneros** es una red social del fútbol creada para registrar, puntuar y comentar partidos en tiempo real. Este repositorio recopila la documentación académica y los scripts en **ANSI SQL** del trabajo práctico integrador de la cátedra **Bases de Datos I (FaCENA–UNNE)**.
 
## Presentación del proyecto
- Dominio de aplicación: gestión colaborativa de partidos de fútbol y opiniones de la comunidad.
- Alcance: diseño lógico del esquema `tribuneros_bdi`, definición de restricciones, carga de datos representativos y consultas de verificación.
- Artefactos clave: capítulos académicos, scripts SQL ejecutables y recursos gráficos de apoyo.

## Objetivos generales
1. Documentar de forma académica el proceso de diseño y validación de la base de datos Tribuneros.
2. Proporcionar scripts reproducibles para crear, poblar y auditar el esquema relacional en SQL Server.
3. Garantizar la trazabilidad entre los capítulos teóricos y la implementación técnica mediante enlaces cruzados.
4. Implementar y documentar un modelo de seguridad basado en roles y permisos granulares.

## Tabla de navegación académica
| Sección | Descripción | Documento |
| --- | --- | --- |
| Portada | Datos institucionales y autores | [docs/portada.md](docs/portada.md) |
| Índice general | Sumario completo del informe | [docs/indice.md](docs/indice.md) |
| Capítulo I | Introducción, problema y objetivos específicos | [docs/capitulo-1-introduccion.md](docs/capitulo-1-introduccion.md) |
| Capítulo II | Marco conceptual y glosario de términos | [docs/capitulo-2-marco-conceptual.md](docs/capitulo-2-marco-conceptual.md) |
| Capítulo III | Metodología de relevamiento y modelado | [docs/capitulo-3-metodologia.md](docs/capitulo-3-metodologia.md) |
| Capítulo IV | Resultados, modelos finales y validación | [docs/capitulo-4-resultados.md](docs/capitulo-4-resultados.md) |
| Capítulo V | Conclusiones y líneas futuras | [docs/capitulo-5-conclusiones.md](docs/capitulo-5-conclusiones.md) |
| Capítulo VI | Bibliografía académica y técnica | [docs/capitulo-6-bibliografia.md](docs/capitulo-6-bibliografia.md) |
| Anexo | Diccionario de datos completo | [docs/diccionario_datos.md](docs/diccionario_datos.md) |
| Modulo 1 |  Manejo de Permisos a Nivel de Usuarios de Base de Datos | [Modulo 1 - Manejo de Permisos a Nivel de Usuarios de Base de Datos](docs/modulo1-permisos.md) |

Cada capítulo enlaza con los scripts relevantes en `script/` para ampliar la trazabilidad técnica.

## Estructura del repositorio
```text
.
├── assets/               # imágenes y recursos gráficos usados en la documentación
│   ├── badge-bdi.png     — Badge/logo que se muestra en el README.
│   └── (otros archivos de imagen/diagramas usados en docs/)
├── docs/                 # circuito documental académico (capítulos, índices y anexos)
│   ├── portada.md                — Portada con datos institucionales, autores y versión.
│   ├── indice.md                 — Índice general y mapa de navegación del informe.
│   ├── capitulo-1-introduccion.md — Introducción, planteo del problema y objetivos.
│   ├── capitulo-2-marco-conceptual.md — Marco teórico, definiciones y glosario.
│   ├── capitulo-3-metodologia.md  — Metodología de relevamiento y decisiones de diseño.
│   ├── capitulo-4-resultados.md   — Resultados, modelo final y referencias a scripts.
│   ├── capitulo-5-conclusiones.md — Conclusiones, limitaciones y líneas futuras.
│   ├── capitulo-6-bibliografia.md — Bibliografía académica y técnica.
│   ├── modulo1-permisos.md -  Manejo de Permisos a Nivel de Usuarios de Base de Datos
│   └── diccionario_datos.md       — Diccionario de datos completo (entidades, atributos, tipos, restricciones y ejemplos).
├── script/               # scripts SQL ordenados para creación, carga, verificación y métricas (SQL Server)
│   ├── creacion.sql          — DDL: creación del esquema `tribuneros_bdi`, tablas, claves, índices y constraints.
│   ├── carga_inicial.sql     — INSERTs para poblar el esquema con un dataset de ejemplo para pruebas.
│   ├── verificacion.sql      — Consultas de control de integridad referencial y reglas de negocio.
│   ├── conteo.sql            — Consultas de métricas y conteos para validar volúmenes y consistencia.
│   └── modulo1-permisos/     # Scripts para configurar y probar el modelo de seguridad.
│       ├── 01_logins_y_usuarios.sql
│       └── (y otros scripts del módulo)
├── README.md             — Introducción, guía rápida y navegación del repositorio (este archivo).
└── LICENSE               — Licencia aplicable: MIT para el código SQL; documento académico bajo CC BY‑NC‑SA 4.0.
```

## Scripts SQL clave
- [script/creacion.sql](script/creacion.sql) — DDL del esquema `tribuneros_bdi` (tablas, claves y restricciones).
- [script/carga_inicial.sql](script/carga_inicial.sql) — Dataset inicial con casos representativos para pruebas.
- [script/verificacion.sql](script/verificacion.sql) — Consultas de control de integridad referencial y de negocio.
- [script/conteo.sql](script/conteo.sql) — Métricas rápidas para validar volúmenes cargados.

Para más detalles de cada script, consulta el Capítulo IV del informe académico.

## Guía rápida de ejecución
1. Crear una base de datos vacía en SQL Server (por ejemplo, `Tribuneros`).
2. Ejecutar en orden los scripts anteriores con **SQL Server Management Studio**, **Azure Data Studio** o `sqlcmd`.
3. Revisar el capítulo de Resultados y el [diccionario de datos](docs/diccionario_datos.md) para interpretar las entidades y relaciones.

## Licencia
- Código SQL: [MIT](LICENSE).
- Documento académico: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

<div align="center">
  <br/>
  <img src="./assets/badge-bdi.png" alt="BDI Badge" height="120"/><br/>
  <sub>❤️🐔 Hecho con pasión y dedicación — FaCENA · UNNE</sub>
</div>
