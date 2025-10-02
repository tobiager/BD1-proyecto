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


---

|  Anterior | Siguiente  |
| --- | --- |
| [Capítulo II — Marco conceptual](capitulo-2-marco-conceptual.md) | [Capítulo IV — Resultados](capitulo-4-resultados.md) |
