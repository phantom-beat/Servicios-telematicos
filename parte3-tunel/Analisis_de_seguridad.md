# Análisis de seguridad

La publicación del servidor Apache mediante un túnel público permite que
el servicio sea accesible desde Internet sin necesidad de realizar una
redirección directa de puertos en el router. Sin embargo, esta
exposición también genera riesgos de seguridad que deben ser
considerados.

## Riesgos identificados

### 1. Exposición pública del servicio

Al utilizar un túnel público, el servidor deja de estar disponible
únicamente dentro de la red local y puede recibir solicitudes
provenientes de Internet. Cualquier usuario que conozca la URL pública
puede intentar acceder al servicio.

### 2. Acceso no autorizado

Si el servidor publicara información privada o recursos que no deberían
estar disponibles para cualquier usuario, estos podrían ser consultados
por personas externas. Por esta razón, no se deben almacenar
credenciales, claves privadas ni archivos sensibles dentro del
directorio público de Apache.

### 3. Ataques contra el servidor web

Las solicitudes recibidas a través del túnel deben considerarse tráfico
no confiable. Un atacante podría intentar realizar solicitudes
maliciosas, explotar vulnerabilidades de Apache o de la aplicación web,
o generar una cantidad elevada de peticiones.

### 4. Exposición prolongada del túnel

Un Quick Tunnel está pensado para pruebas y demostraciones. Mantenerlo
activo después de finalizar la práctica prolongaría innecesariamente la
exposición del servicio hacia Internet.

## Medidas de mitigación

### 1. Detener el túnel después de la demostración

Una vez terminadas las pruebas, se debe detener el proceso de
`cloudflared`. De esta manera, el servicio deja de estar disponible
públicamente y se reduce la superficie de exposición.

### 2. Implementar autenticación

Si el servicio tuviera que permanecer publicado, se recomienda
implementar mecanismos de autenticación para evitar que cualquier
usuario pueda acceder a recursos privados.

### 3. Restringir el acceso

Cuando las características del servicio lo permitan, se pueden aplicar
restricciones mediante direcciones IP, reglas de firewall o controles de
acceso para limitar quién puede conectarse al servidor.

### 4. Proteger el contenido publicado

El `DocumentRoot` de Apache debe contener únicamente los archivos
necesarios para el funcionamiento del sitio. No se deben publicar
archivos de configuración, contraseñas, claves privadas ni información
sensible.

### 5. Mantener el servidor actualizado

Apache, el sistema operativo y los módulos utilizados deben mantenerse
actualizados para reducir el riesgo de explotación de vulnerabilidades
conocidas.

## Conclusión del análisis

El uso de Cloudflare Tunnel permite publicar el servicio de forma
práctica sin abrir directamente el puerto 80 del servidor hacia
Internet. Sin embargo, el hecho de que el servicio sea accesible
públicamente implica riesgos de acceso no autorizado y ataques contra el
servidor.

Para una demostración académica, el uso de un Quick Tunnel temporal
resulta adecuado, siempre que se cierre al finalizar. Para un servicio
permanente sería necesario complementar la publicación con
autenticación, restricciones de acceso, protección de archivos sensibles
y mantenimiento actualizado del servidor.
