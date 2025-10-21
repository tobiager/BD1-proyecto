-- =========================================================
-- TRIBUNEROS - Script Maestro de Ejecución Completo
-- =========================================================
-- Este script ejecuta todos los componentes del proyecto
-- en el orden correcto, incluyendo los anexos técnicos.
-- 
-- IMPORTANTE: Revise cada sección antes de ejecutar.
-- Algunos scripts (especialmente Cap11) pueden tardar 
-- varios minutos en completarse.
-- =========================================================

USE master;
GO

PRINT '==================================================';
PRINT 'TRIBUNEROS - Implementación Completa';
PRINT 'Base de Datos I - FaCENA UNNE';
PRINT '==================================================';
PRINT '';

-- =========================================================
-- FASE 1: CREACIÓN DEL ESQUEMA BASE
-- =========================================================
PRINT '==================================================';
PRINT 'FASE 1: CREACIÓN DEL ESQUEMA BASE';
PRINT '==================================================';
PRINT 'Ejecutando: script/creacion.sql';
PRINT 'Crea la base de datos y todas las tablas.';
PRINT '';

-- El script de creación crea la BD y hace USE
:r script/creacion.sql

PRINT 'Fase 1 completada.';
PRINT '';

-- =========================================================
-- FASE 2: CARGA DE DATOS INICIALES
-- =========================================================
PRINT '==================================================';
PRINT 'FASE 2: CARGA DE DATOS INICIALES';
PRINT '==================================================';
PRINT 'Ejecutando: script/carga_inicial.sql';
PRINT 'Inserta datos representativos para pruebas.';
PRINT '';

:r script/carga_inicial.sql

PRINT 'Fase 2 completada.';
PRINT '';

-- =========================================================
-- FASE 3: VERIFICACIÓN DE INTEGRIDAD
-- =========================================================
PRINT '==================================================';
PRINT 'FASE 3: VERIFICACIÓN DE INTEGRIDAD';
PRINT '==================================================';
PRINT 'Ejecutando: script/verificacion.sql';
PRINT 'Valida integridad referencial y de negocio.';
PRINT '';

:r script/verificacion.sql

PRINT 'Fase 3 completada.';
PRINT '';

-- =========================================================
-- FASE 4: CONTEO Y VALIDACIÓN
-- =========================================================
PRINT '==================================================';
PRINT 'FASE 4: CONTEO Y VALIDACIÓN';
PRINT '==================================================';
PRINT 'Ejecutando: script/conteo.sql';
PRINT 'Verifica volúmenes de datos cargados.';
PRINT '';

:r script/conteo.sql

PRINT 'Fase 4 completada.';
PRINT '';

-- =========================================================
-- ANEXOS TÉCNICOS AVANZADOS
-- =========================================================
PRINT '==================================================';
PRINT 'ANEXOS TÉCNICOS AVANZADOS';
PRINT '==================================================';
PRINT '';
PRINT 'Los siguientes anexos demuestran características avanzadas:';
PRINT '  - Anexo I: Seguridad y Permisos';
PRINT '  - Anexo II: Procedimientos y Funciones';
PRINT '  - Anexo III: Optimización con Índices';
PRINT '';
PRINT 'NOTA: Puede ejecutar estos anexos de forma independiente';
PRINT '      según sus necesidades.';
PRINT '';

-- =========================================================
-- ANEXO I: SEGURIDAD Y PERMISOS
-- =========================================================
PRINT '==================================================';
PRINT 'ANEXO I: SEGURIDAD Y PERMISOS';
PRINT '==================================================';
PRINT '';
PRINT 'REQUISITO: Servidor en modo de autenticación mixto';
PRINT '¿Desea ejecutar el Anexo I? (Configuración manual requerida)';
PRINT '';
PRINT '-- Para ejecutar manualmente:';
PRINT '-- :r scripts/Cap09_Seguridad/01_Configuracion_Usuarios.sql';
PRINT '-- :r scripts/Cap09_Seguridad/02_Configuracion_Roles.sql';
PRINT '-- :r scripts/Cap09_Seguridad/03_Pruebas_Permisos.sql';
PRINT '';

-- Descomentar las siguientes líneas para ejecutar automáticamente
-- :r scripts/Cap09_Seguridad/01_Configuracion_Usuarios.sql
-- :r scripts/Cap09_Seguridad/02_Configuracion_Roles.sql
-- :r scripts/Cap09_Seguridad/03_Pruebas_Permisos.sql

-- =========================================================
-- ANEXO II: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
-- =========================================================
PRINT '==================================================';
PRINT 'ANEXO II: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS';
PRINT '==================================================';
PRINT 'Ejecutando scripts de procedimientos y funciones...';
PRINT '';

:r scripts/Cap10_Procedimientos_Funciones/01_Procedimientos_Almacenados.sql
:r scripts/Cap10_Procedimientos_Funciones/02_Funciones_Almacenadas.sql

PRINT '';
PRINT 'Procedimientos y funciones creados.';
PRINT '';
PRINT 'Para ejecutar pruebas comparativas:';
PRINT ':r scripts/Cap10_Procedimientos_Funciones/03_Pruebas_Comparativas.sql';
PRINT '';

-- Descomentar para ejecutar pruebas automáticamente
-- :r scripts/Cap10_Procedimientos_Funciones/03_Pruebas_Comparativas.sql

-- =========================================================
-- ANEXO III: OPTIMIZACIÓN CON ÍNDICES
-- =========================================================
PRINT '==================================================';
PRINT 'ANEXO III: OPTIMIZACIÓN CON ÍNDICES';
PRINT '==================================================';
PRINT '';
PRINT 'ADVERTENCIA: Este anexo insertará 1,000,000+ registros';
PRINT '             y puede tardar 5-15 minutos.';
PRINT '';
PRINT '¿Desea ejecutar el Anexo III? (Configuración manual requerida)';
PRINT '';
PRINT '-- Para ejecutar manualmente:';
PRINT '-- :r scripts/Cap11_Indices/01_Carga_Masiva.sql';
PRINT '-- :r scripts/Cap11_Indices/02_Pruebas_Performance.sql';
PRINT '-- :r scripts/Cap11_Indices/03_Resultados_Analisis.sql';
PRINT '';

-- Descomentar las siguientes líneas para ejecutar automáticamente
-- ADVERTENCIA: Insertará 1M+ registros y tardará varios minutos
-- :r scripts/Cap11_Indices/01_Carga_Masiva.sql
-- :r scripts/Cap11_Indices/02_Pruebas_Performance.sql
-- :r scripts/Cap11_Indices/03_Resultados_Analisis.sql

-- =========================================================
-- RESUMEN FINAL
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE EJECUCIÓN';
PRINT '==================================================';
PRINT '';
PRINT 'Componentes implementados:';
PRINT '  ✓ Esquema de base de datos completo';
PRINT '  ✓ Datos iniciales representativos';
PRINT '  ✓ Verificaciones de integridad';
PRINT '  ✓ Procedimientos almacenados con validaciones';
PRINT '  ✓ Funciones reutilizables';
PRINT '';
PRINT 'Componentes opcionales (ejecutar manualmente):';
PRINT '  ○ Configuración de seguridad (Anexo I)';
PRINT '  ○ Pruebas comparativas de SPs (Anexo II)';
PRINT '  ○ Carga masiva y pruebas de índices (Anexo III)';
PRINT '';
PRINT 'Documentación disponible en:';
PRINT '  - docs/diccionario_datos.md';
PRINT '  - docs/anexo-1-seguridad.md';
PRINT '  - docs/anexo-2-procedimientos-funciones.md';
PRINT '  - docs/anexo-3-indices.md';
PRINT '';
PRINT 'Base de datos: tribuneros_bdi';
PRINT 'Estado: Lista para usar';
PRINT '';
PRINT '==================================================';
PRINT 'Implementación completada exitosamente.';
PRINT '==================================================';
GO
