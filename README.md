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

## ✨ Características destacadas

### 🗄️ Esquema Relacional Completo
- 12 tablas relacionadas con integridad referencial
- Restricciones CHECK para validación de dominios
- Índices optimizados para consultas frecuentes
- Compatible con SQL Server 2016+

### 🔐 Seguridad y Permisos (Anexo I)
- Usuarios con diferentes niveles de acceso (admin, lectura, roles personalizados)
- Demostración de ownership chaining
- Implementación del principio de menor privilegio
- 6 pruebas automatizadas de permisos

### ⚙️ Procedimientos y Funciones (Anexo II)
- 3 procedimientos almacenados con 8+ validaciones cada uno
- 3 funciones reutilizables para cálculos frecuentes
- Manejo robusto de errores con TRY-CATCH
- Pruebas comparativas de rendimiento

### 🚀 Optimización con Índices (Anexo III)
- Dataset de prueba: 1,000,000+ registros
- Comparación de 3 estrategias de indexación
- Mejora demostrada de 10-20x en rendimiento
- Análisis con planes de ejecución y DMVs
- Scripts de diagnóstico y mantenimiento

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

## Anexos técnicos avanzados
| Anexo | Descripción | Scripts | Documentación |
| --- | --- | --- | --- |
| Anexo I | Seguridad y permisos: configuración de usuarios, roles y pruebas | [script/Cap09_Seguridad](script/Cap09_Seguridad/) | [anexo-1-seguridad.md](docs/anexo-1-seguridad.md) |
| Anexo II | Procedimientos y funciones almacenadas con pruebas comparativas | [script/Cap10_Procedimientos_Funciones](script/Cap10_Procedimientos_Funciones/) | [anexo-2-procedimientos-funciones.md](docs/anexo-2-procedimientos-funciones.md) |
| Anexo III | Optimización con índices: carga masiva y análisis de performance | [script/Cap11_Indices](script/Cap11_Indices/) | [anexo-3-indices.md](docs/anexo-3-indices.md) |

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

## Scripts avanzados de seguridad, procedimientos e índices
- [script/Cap09_Seguridad](script/Cap09_Seguridad/) — Configuración de usuarios, roles y pruebas de permisos
- [script/Cap10_Procedimientos_Funciones](script/Cap10_Procedimientos_Funciones/) — Procedimientos almacenados, funciones y pruebas comparativas
- [script/Cap11_Indices](script/Cap11_Indices/) — Carga masiva de datos y optimización con índices

Para más detalles de cada script, consulta el Capítulo IV del informe académico.

## Guía rápida de ejecución

### Opción A: Ejecución automática (recomendada)
```sql
-- Desde SQL Server Management Studio o Azure Data Studio
-- Abrir y ejecutar el script maestro:
:r /ruta/completa/script/00_Maestro_Ejecucion.sql
```

El script maestro ejecuta automáticamente las fases 1-4 y crea procedimientos/funciones. Los anexos opcionales requieren ejecución manual.

Ver [Guía detallada de scripts](scripts/README.md) para más opciones.

### Opción B: Ejecución manual por fases

#### Fase 1-4: Esquema básico (requerido)
1. Crear una base de datos vacía en SQL Server
2. Ejecutar scripts del directorio `script/` en orden:
   - `creacion.sql` — Crea el esquema completo
   - `carga_inicial.sql` — Inserta datos de prueba
   - `verificacion.sql` — Valida la integridad
   - `conteo.sql` — Verifica cantidades
3. Revisar el [diccionario de datos](docs/diccionario_datos.md)

#### Anexo I: Seguridad y permisos (opcional)
**Prerequisito**: Configurar modo de autenticación mixto en SQL Server

Ejecutar scripts en orden desde `scripts/Cap09_Seguridad/`:
1. `01_Configuracion_Usuarios.sql` — Crea Admin_Usuario y LecturaSolo_Usuario
2. `02_Configuracion_Roles.sql` — Crea RolLectura y usuarios de prueba
3. `03_Pruebas_Permisos.sql` — Valida permisos configurados

Documentación: [anexo-1-seguridad.md](docs/anexo-1-seguridad.md)

#### Anexo II: Procedimientos y funciones (recomendado)
Ejecutar scripts desde `scripts/Cap10_Procedimientos_Funciones/`:
1. `01_Procedimientos_Almacenados.sql` — sp_InsertPartido, sp_UpdatePartido, sp_DeletePartido
2. `02_Funciones_Almacenadas.sql` — fn_CalcularEdad, fn_ObtenerPromedioCalificaciones, fn_ContarPartidosPorEstado
3. `03_Pruebas_Comparativas.sql` — Pruebas de eficiencia (opcional)

Documentación: [anexo-2-procedimientos-funciones.md](docs/anexo-2-procedimientos-funciones.md)

#### Anexo III: Optimización con índices (opcional, avanzado)
⚠️ **ADVERTENCIA**: La carga masiva insertará 1M+ registros y puede tardar 5-15 minutos

Ejecutar scripts desde `scripts/Cap11_Indices/`:
1. `01_Carga_Masiva.sql` — Inserta 1,000,000+ registros (⏱ 5-15 min)
2. `02_Pruebas_Performance.sql` — Compara estrategias de indexación
3. `03_Resultados_Analisis.sql` — Análisis y diagnóstico

Documentación: [anexo-3-indices.md](docs/anexo-3-indices.md)

## 📊 Resultados y Métricas

### Seguridad (Anexo I)
- ✅ 4 usuarios configurados con permisos diferenciados
- ✅ 1 rol personalizado para lectura selectiva
- ✅ Ownership chaining funcionando correctamente
- ✅ 100% de pruebas de permisos exitosas

### Procedimientos y Funciones (Anexo II)
- ✅ 3 procedimientos con validaciones exhaustivas
- ✅ 3 funciones reutilizables
- ⏱️ Overhead: 50-100% más lento que INSERT directo
- ✅ Beneficio: Integridad de datos garantizada

### Optimización con Índices (Anexo III)
| Métrica | Sin Índice | Índice Simple | Índice Covering | Mejora |
|---------|-----------|---------------|-----------------|--------|
| Lecturas lógicas | 50,000 | 8,000 | 1,500 | **97%** ↓ |
| Tiempo (ms) | 1,500 | 450 | 120 | **92%** ↓ |
| Mejora vs base | 1x | 3-4x | **10-20x** | — |

**Conclusión**: Los índices covering reducen tiempos de consulta en un **92%** con un costo de espacio < 5%.

## Licencia
- Código SQL: [MIT](LICENSE).
- Documento académico: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

<div align="center">
  <br/>
  <img src="./assets/badge-bdi.png" alt="BDI Badge" height="120"/><br/>
  <sub>❤️🐔 Hecho con pasión y dedicación — FaCENA · UNNE</sub>
</div>
