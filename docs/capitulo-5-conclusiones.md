# Capítulo V — Conclusiones

## Síntesis de hallazgoss
- El modelo de datos desarrollado satisface los requerimientos principales de la plataforma Tribuneros, permitiendo almacenar interacciones complejas entre usuarios, partidos y contenido generado por la comunidad.
- Las restricciones implementadas en [`script/creacion.sql`](../script/creacion.sql) y validadas con [`script/verificacion.sql`](../script/verificacion.sql) aseguran integridad referencial y control de dominios, reduciendo errores durante la carga.
- La documentación generada (capítulos, índice y diccionario) consolida un circuito claro para revisión académica y facilita la trazabilidad entre narrativa, decisiones técnicas y scripts ejecutables.

## Líneas futuras
1. **Ampliar la carga de datos** con casos que representen distintas competencias, fases del torneo y diversidad de usuarios, extendiendo [`script/carga_inicial.sql`](../script/carga_inicial.sql).
2. **Incorporar métricas avanzadas** de reputación y recomendación, apoyándose en vistas o procedimientos almacenados que se sumen a los scripts existentes.
3. **Integrar automatizaciones** (tests unitarios SQL, pipelines CI) que ejecuten `creacion.sql`, `carga_inicial.sql` y `verificacion.sql` en ambientes controlados.
4. **Diseñar APIs y prototipos de interfaz** que consuman la base, reutilizando el diccionario y los diagramas para alinear implementaciones futuras.


---

|  Anterior | Siguiente  |
| --- | --- |
| [Capítulo IV — Resultados](capitulo-4-resultados.md) | [Capítulo VI — Bibliografía](capitulo-6-bibliografia.md) |
