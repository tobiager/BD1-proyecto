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

## Documentación
| Documento | Descripción |
|---|---|
| [`docs/tema1-informe.md`](./docs/tema1-informe.md) | Informe del **Tema 1: Procedimientos y Funciones** (objetivos, implementación, pruebas y conclusiones). |
| [`docs/diccionario_datos.md`](./docs/diccionario_datos.md) | Diccionario de datos del esquema `tribuneros_bdi`. |
| [`docs/Proyecto_Integrador_Grupo39.pdf`](./docs/Proyecto_Integrador_Grupo39.pdf) | **Consolidado del informe académico** (Cap. I–VI). Falta completar contenido por tema. |

> Cada documento técnico referencia los scripts correspondientes en `script/` para garantizar trazabilidad.


## Estructura del repositorio
```text
.
├─ assets/
│  ├─ badge-bdi.png
│  ├─ der-tribuneros.png
│  └─ tema1-procs-funciones/        # recursos del tema 1
├─ docs/
│  ├─ diccionario_datos.md
│  ├─ Proyecto_Integrador_Grupo39.pdf
│  └─ tema1-informe.md
├─ script/
│  ├─ creacion.sql                   # DDL: esquema, PK/FK, constraints, índices base
│  ├─ carga_inicial.sql              # datos representativos
│  ├─ verificacion.sql               # controles de integridad y de negocio
│  ├─ conteo.sql                     # métricas y conteos rápidos
│  ├─ limpieza_datos.sql             # utilitario de limpieza básica (dataset)
│  └─ tema1-procs-funciones/
│     ├─ 01_procedimientos.sql
│     ├─ 02_funciones.sql
│     ├─ 03_datos_insert_directo.sql
│     ├─ 04_datos_insert_via_sp.sql
│     ├─ 05_pruebas_funciones.sql
│     ├─ 06_pruebas_procedimientos.sql
│     └─ 07_limpieza_total.sql       # rollback de datos de pruebas del Tema 1
├─ LICENSE
└─ README.md                         # este archivo
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
