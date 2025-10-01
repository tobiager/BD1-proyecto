# Capítulo II — Marco conceptual o referencial

> **Propósito**. Este capítulo reúne los conceptos, supuestos y definiciones operativas que enmarcan **Tribuneros**, una red social del fútbol para registrar, puntuar y comentar partidos. Sirve para ubicar el problema dentro de un cuerpo de conocimientos (plataformas sociales, contenido generado por usuarios, reputación, engagement, curaduría y moderación) y para estandarizar los términos que se usarán en el modelo de datos y en el análisis posterior.

---

## 2.1. Enfoque y delimitación del problema

* **Tema**: registro social de experiencias de visionado de fútbol (partidos vistos) y producción de reseñas/calificaciones con control de spoilers.
* **Objeto de estudio**: las **interacciones** entre usuarios, partidos y contenido (visualizaciones, calificaciones, opiniones, favoritos, seguimientos, recordatorios y curaduría de destacados).
* **Unidad de análisis**: usuario, partido y publicación (opinión/calificación) como entidades primarias.
* **Ámbito**: ligas y equipos profesionales (extensible a selecciones y copas), con foco en el consumo pos‑partido y la conversación segura (sin spoilers).

---

## 2.2. Conceptos clave

1. **Plataforma social (social network)**

   * *Definición operativa*: sistema multiusuario con perfiles, publicaciones y vínculos (seguir equipos, marcar favoritos), persistidos en tablas `usuarios`, `perfiles_usuario`, `opiniones_partido`, `favoritos` y `seguir_equipos`.
   * *Rol*: infraestructura sociotécnica que habilita la interacción y el efecto red.

2. **Contenido generado por usuarios (UGC)**

   * *Definición operativa*: opiniones, calificaciones y reseñas creadas por personas usuarias respecto de un **partido** (`opiniones_partido`, `calificaciones_partido`).
   * *Rol*: insumo central para la experiencia, la reputación y la curaduría.

3. **Experiencia de visualización**

   * *Definición operativa*: acto de ver un partido con metadatos de medio y duración (`visualizaciones`: `medium`, `minutes_watched`, `viewed_at`).
   * *Rol*: fuente primaria de verdad para habilitar calificar/comentar y para métricas de consumo.

4. **Calificación (rating)**

   * *Definición operativa*: valoración numérica discreta del partido (p.ej., 1–5) registrada en `calificaciones_partido.rating`.
   * *Rol*: variable cuantitativa para rankings, promedios y recomendaciones básicas.

5. **Opinión / Reseña**

   * *Definición operativa*: publicación textual con banderas `is_public` y `has_spoilers` en `opiniones_partido`, con marca temporal de creación/edición.
   * *Rol*: canal cualitativo para discusión y memoria del partido; su visibilidad depende de privacidad y spoilers.

6. **Spoilers**

   * *Definición operativa*: revelación de eventos clave (marcador, goles decisivos) marcada por `has_spoilers=true`.
   * *Rol*: mecanismo de **protección de experiencia** que condiciona el feed y las reglas de visibilidad.

7. **Privacidad**

   * *Definición operativa*: ámbito de publicación `is_public` (público/privado) en opiniones y controles de perfil.
   * *Rol*: determinante del alcance del contenido y del cumplimiento normativo.

8. **Seguimiento y favoritos**

   * *Definición operativa*: relación de interés del usuario con `equipos` (`seguir_equipos`) y marcación de `partidos` como favoritos.
   * *Rol*: personalización del feed y de las notificaciones.

9. **Curaduría / Partidos destacados**

   * *Definición operativa*: selección editorial o algorítmica registrada en `partidos_destacados` (`featured_on`, `curated_by`, `note`).
   * *Rol*: aumentar descubrimiento y conversación de calidad.

10. **Recordatorios**

    * *Definición operativa*: programación de alertas para un partido (`recordatorios.remind_at`, `status`).
    * *Rol*: elevar intención de visualización y completar el ciclo *ver → calificar → opinar*.

11. **Reputación y confianza**

    * *Definición operativa*: señales derivadas del historial (antigüedad de cuenta, proporción de opiniones públicas, consistencia de calificaciones). En esta versión se infiere a partir de actividad; queda abierta la futura métrica explícita (p. ej., karma).
    * *Rol*: ordenar el feed y priorizar contenido de calidad.

12. **Integridad e interoperabilidad de datos**

    * *Definición operativa*: claves foráneas y estados válidos (`estado_partido`) que garantizan consistencia entre `ligas`, `equipos` y `partidos`.
    * *Rol*: base para reportes confiables y evolución del modelo.
