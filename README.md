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

**Tribuneros** es una red social del fútbol creada para registrar, puntuar y comentar partidos en tiempo real. Este repositorio recopila la documentación académica y los scripts T-SQL del trabajo práctico integrador de la cátedra **Bases de Datos I (FaCENA–UNNE)**.

## Presentación del proyecto
- Dominio de aplicación: gestión colaborativa de partidos de fútbol y opiniones de la comunidad.
- Alcance: diseño lógico del esquema `tribuneros_bdi`, definición de restricciones, carga de datos representativos y consultas de verificación.
- Artefactos clave: capítulos académicos, scripts SQL ejecutables y recursos gráficos de apoyo.

## Objetivos generales
1. Documentar de forma académica el proceso de diseño y validación de la base de datos Tribuneros.
2. Proporcionar scripts reproducibles para crear, poblar y auditar el esquema relacional en SQL Server.
3. Garantizar la trazabilidad entre los capítulos teóricos y la implementación técnica mediante enlaces cruzados.

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

Cada capítulo enlaza con los scripts relevantes en `script/` para ampliar la trazabilidad técnica.

## Estructura del repositorio
- [`docs/`](docs/) — Circuito documental académico (portada, índice, capítulos y anexos).
- [`script/`](script/) — Scripts SQL ordenados para creación, carga, verificación y métricas.
- [`assets/`](assets/) — Recursos gráficos utilizados en presentaciones y documentación.
- [`README.md`](README.md) — Introducción y guía rápida del proyecto.
- [`LICENSE`](LICENSE) — Licencia abierta aplicable a código y documentos.

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
