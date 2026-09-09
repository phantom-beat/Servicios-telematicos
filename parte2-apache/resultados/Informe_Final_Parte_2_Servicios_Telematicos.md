Servicios Telemáticos — Parte 2 — Apache 

## **UNIVERSIDAD AUTÓNOMA DE OCCIDENTE** 

### **SERVICIOS TELEMÁTICOS** 

# **INFORME FINAL — PARTE 2** 

Apache, VirtualHosts, DNS y evaluación experimental de compresión HTTP 

**Integrantes:** Gabriel Armando Gil Jose David Aguirre Salinas 

**Asignatura:** Servicios Telemáticos 

**Entorno:** Ubuntu Server + Windows + VirtualBox/Vagrant 

**DNS maestro:** 192.168.50.2 **DNS esclavo:** 192.168.50.3 

**Servidor web:** 192.168.50.10 

**Dominio:** empresa.local 

**Sitio de medición:** parcial.empresa.local 

**Fecha :** 8 de septiembre de 2026 

Informe actualizado — septiembre de 2026 

Servicios Telemáticos — Parte 2 — Apache 

#### **1. Objetivo** 

Implementar y verificar Apache2 mediante VirtualHosts, resolución DNS local, cabeceras HTTP de seguridad y compresión con Gzip (mod_deflate) y Brotli (mod_brotli). La evaluación experimental mide el tamaño transferido y el tiempo total para varios tipos de recursos. 

#### **2. Arquitectura** 

|**Equipo**|**IP**|**Función**|
|---|---|---|
|maestro.empresa.local|192.168.50.2|DNS maestro BIND9|
|esclavo.empresa.local|192.168.50.3|DNS esclavo BIND9|
|web|192.168.50.10|Apache2 / VirtualHosts|
|mail.empresa.local|192.168.50.20|Correo|
|api.empresa.local|192.168.50.30|API|
|parcial.empresa.local|192.168.50.10|Sitio de medición|



#### **3. VirtualHosts y Apache** 

La configuración de Apache fue validada con apache2ctl. Se observaron los VirtualHosts api.empresa.local, parcial.empresa.local y www.empresa.local en el puerto 80. El DocumentRoot de parcial.empresa.local es /var/www/parcial.empresa.local/html. 

La sintaxis de Apache fue validada repetidamente durante la medición y el resultado fue Syntax OK. 

Para el sitio parcial se verificó que clip.mp4 existe en el DocumentRoot, pertenece a www-data y es legible. La solicitud HTTP de este recurso respondió 200 OK con Content-Type: video/mp4. 

#### **4. Resolución DNS** 

Inicialmente la VM web no resolvía parcial.empresa.local mediante systemd-resolved, aunque una consulta directa con dig @192.168.50.2 sí devolvía 192.168.50.10. Se configuró systemd-resolved para utilizar 192.168.50.2 y el dominio de ruteo ~empresa.local. 

- sudo systemctl restart systemd-resolved 

- sudo resolvectl flush-caches 

- sudo resolvectl dns enp0s3 192.168.50.2 

- sudo resolvectl domain enp0s3 '~empresa.local' 

Verificación final: resolvectl query parcial.empresa.local devolvió 192.168.50.10 y getent hosts parcial.empresa.local devolvió 192.168.50.10 parcial.empresa.local. 

#### **5. Pruebas HTTP** 

- curl -I -H "Host: parcial.empresa.local" http://127.0.0.1/ 

- curl -I -H "Host: parcial.empresa.local" http://127.0.0.1/clip.mp4 

Resultados verificados: la raíz del sitio respondió HTTP/1.1 200 OK; clip.mp4 respondió HTTP/1.1 200 OK y Content-Type: video/mp4. 

#### **6. Cabeceras de seguridad** 

- X-Content-Type-Options: nosniff — presente en la verificación registrada. 

- X-Frame-Options: SAMEORIGIN — presente en la verificación registrada. 

Informe actualizado — septiembre de 2026 

Servicios Telemáticos — Parte 2 — Apache 

- X-XSS-Protection: 1; mode=block — presente en la verificación registrada. 

- Referrer-Policy: strict-origin-when-cross-origin — presente en la verificación registrada. 

#### **7. Configuración de compresión** 

Se aplicó compresión a HTML, CSS, JavaScript, JSON, XML, SVG y texto plano. JPEG, PNG, MP4 y ZIP se mantienen excluidos porque ya utilizan mecanismos de compresión propios. 

Niveles evaluados: Gzip 1, 6 y 9; Brotli 5 y 11. Identity se utilizó como línea base. 

#### **8. Metodología** 

El script medir_compresion.sh realizó las solicitudes con curl, registrando tamaño original, tamaño transferido, ratio, porcentaje de ahorro, tiempo total, CPU de usuario de curl y Content-Encoding. Los resultados se guardaron en resultados.csv y resultados.md. 

Script: /vagrant/parte2-apache/scripts/medir_compresion.sh 

Resultados: /vagrant/parte2-apache/resultados/resultados.csv y /vagrant/parte2-apache/resultados/resultados.md 

#### **9. Recursos evaluados** 

|**Recurso**|**MIME**|**Original (B)**|
|---|---|---|
|index.html|text/html|194481|
|estilos.css|text/css|311900|
|app.js|application/javascript|608013|
|datos.json|application/json|2205391|
|grafico.svg|image/svg+xml|187306|
|feed.xml|text/xml|508870|
|lorem.txt|text/plain|1880000|



#### **10. Resultados completos** 

Los siguientes valores corresponden a la ejecución real más reciente del script. 

|**Recurso**|**Alg.**|**Nivel**|**Original**|**Transferido**|**Ratio**|**Ahorro %**|**Tiempo s**|**CPU s**|**Encoding**|
|---|---|---|---|---|---|---|---|---|---|
|index.html|identity|base|194481|194481|1.000000|0.000|<br>0.015465|0.02|identity|
|estilos.css|identity|base|311900|311900|1.000000|0.000|0.018899|0.02|identity|
|app.js|identity|base|608013|608013|1.000000|0.000|0.019116|0.02|identity|
|datos.json|identity|base|2205391|2205391|1.000000|0.000|5.045466|0.02|identity|
|grafico.svg|identity|base|187306|187306|1.000000|0.000|0.014091|0.02|identity|
|feed.xml|identity|base|508870|508870|1.000000|0.000|0.016066|0.01|identity|
|lorem.txt|identity|base|1880000|1880000|1.000000|0.000|0.026864|0.02|identity|
|index.html|gzip|1|194481|5939|0.030538|96.946|0.021646|0.02|gzip|
|estilos.css|gzip|1|311900|6308|0.020224|97.978|0.021425|0.01|gzip|
|app.js|gzip|1|608013|22909|0.037678|96.232|0.020995|0.01|gzip|
|datos.json|gzip|1|2205391|134477|0.060976|93.902|0.046148|0.01|gzip|
|grafico.svg|gzip|1|187306|42099|0.224761|77.524|0.017888|0.01|gzip|
|feed.xml|gzip|1|508870|21033|0.041333|95.867|0.016101|0.01|gzip|
|lorem.txt|gzip|1|1880000|13454|0.007156|99.284|0.033294|0.02|gzip|
|index.html|gzip|6|194481|5692|0.029268|97.073|0.011221|0.00|gzip|
|estilos.css|gzip|6|311900|2091|0.006704|99.330|0.012017|0.00|gzip|
|app.js|gzip|6|608013|21617|0.035554|96.445|0.014027|0.01|gzip|
|datos.json|gzip|6|2205391|108117|0.049024|95.098|0.036547|0.01|gzip|
|grafico.svg|gzip|6|187306|24035|0.128319|87.168|0.030752|0.01|gzip|
|feed.xml|gzip|6|508870|20349|0.039989|96.001|0.026470|0.01|gzip|
|lorem.txt|gzip|6|1880000|7470|0.003973|99.603|0.043550|0.02|gzip|
|index.html|gzip|9|194481|4525|0.023267|97.673|0.021032|0.02|gzip|
|estilos.css|gzip|9|311900|2090|0.006701|99.330|0.013932|0.01|gzip|
|app.js|gzip|9|608013|21370|0.035147|96.485|0.024971|0.02|gzip|
|datos.json|gzip|9|2205391|84454|0.038294|96.171|0.258578|0.02|gzip|
|grafico.svg|gzip|9|187306|22038|0.117658|88.234|0.072641|0.01|gzip|
|feed.xml|gzip|9|508870|20043|0.039387|96.061|0.023024|0.02|gzip|
|lorem.txt|gzip|9|1880000|7470|0.003973|99.603|0.023458|0.01|gzip|
|index.html|brotli|5|194481|2579|0.013261|98.674|0.021850|0.00|br|
|estilos.css|brotli|5|311900|291|0.000933|99.907|0.017345|0.01|br|



Informe actualizado — septiembre de 2026 

Servicios Telemáticos — Parte 2 — Apache 

|app.js|brotli|5|608013|9304|0.015302|98.470|0.023858|0.01|br|
|---|---|---|---|---|---|---|---|---|---|
|datos.json|brotli|5|2205391|34728|0.015747|98.425|0.522399|0.03|br|
|grafico.svg|brotli|5|187306|15928|0.085037|91.496|0.022652|0.01|br|
|feed.xml|brotli|5|508870|7568|0.014872|98.513|0.033237|0.01|br|
|lorem.txt|brotli|5|1880000|187|0.000099|99.990|0.027471|0.02|br|
|index.html|brotli|11|194481|3412|0.017544|98.246|1.648426|0.01|br|
|estilos.css|brotli|11|311900|270|0.000866|99.913|0.176366|0.01|br|
|app.js|brotli|11|608013|8693|0.014297|98.570|4.672388|0.01|br|
|datos.json|brotli|11|2205391|37147|0.016844|98.316|15.701539|0.02|br|
|grafico.svg|brotli|11|187306|10319|0.055092|94.491|0.777862|0.01|br|
|feed.xml|brotli|11|508870|6325|0.012430|98.757|3.091451|0.01|br|
|lorem.txt|brotli|11|1880000|132|0.000070|99.993|0.089448|0.01|br|



#### **11. Análisis de resultados** 

Sin compresión, cada recurso se transfirió con su tamaño original. La compresión redujo de forma muy significativa el tráfico de los recursos textuales. 

Gzip nivel 9 alcanzó, por ejemplo, 96,171 % de ahorro en datos.json y 99,603 % en lorem.txt. Gzip nivel 6 produjo resultados muy próximos en varios recursos. 

Brotli presentó los mejores ratios globales. Con Brotli 5, datos.json bajó a 34.728 B, un ahorro de 98,425 %. lorem.txt bajó a 187 B, un ahorro de 99,990 %. 

Brotli 11 consiguió algunos tamaños ligeramente menores, pero aumentó fuertemente el tiempo de procesamiento. En datos.json tardó 15,701539 s frente a 0,522399 s con Brotli 5; en app.js tardó 4,672388 s frente a 0,023858 s. 

Por equilibrio entre reducción de tamaño y coste de procesamiento, Brotli 5 resulta una opción práctica para este escenario. Gzip 6 también representa una alternativa equilibrada. 

#### **12. Archivos excluidos de compresión** 

|**Recurso**|**Razón**|**Resultado**|
|---|---|---|
|foto.jpg|JPEG ya está comprimido|SinContent-Encoding|
|imagen.png|PNG ya está comprimido|SinContent-Encoding|
|clip.mp4|Video ya comprimido/codificado|SinContent-Encoding|
|paquete.zip|ZIPya está comprimido|SinContent-Encoding|



#### **13. Estado final** 

- DNS: parcial.empresa.local resuelve a 192.168.50.10. 

- Apache: configuración validada con Syntax OK. 

- VirtualHost parcial: operativo. 

- HTTP: raíz y clip.mp4 responden correctamente. 

- Gzip: niveles 1, 6 y 9 medidos. 

- Brotli: calidades 5 y 11 medidas. 

- Resultados: CSV y Markdown generados correctamente. 

#### **14. Conclusiones** 

La Parte 2 quedó operativa y experimentalmente verificada. Apache entrega el sitio parcial.empresa.local y el DNS local permite su resolución desde la VM web. 

Las mediciones demuestran que Brotli obtiene los mayores porcentajes de ahorro en los recursos de texto evaluados. Sin embargo, Brotli 11 tiene un coste temporal muy superior en recursos grandes, por lo que Brotli 5 ofrece un mejor equilibrio. 

Informe actualizado — septiembre de 2026 

Servicios Telemáticos — Parte 2 — Apache 

La exclusión de JPEG, PNG, MP4 y ZIP evita aplicar compresión HTTP redundante a formatos que ya están comprimidos. 

#### **15. Comandos clave para la sustentación** 

- resolvectl query parcial.empresa.local 

- sudo apache2ctl -t 

- sudo apache2ctl -S 

- curl -I -H "Host: parcial.empresa.local" http://127.0.0.1/ 

- curl -I -H "Host: parcial.empresa.local" http://127.0.0.1/clip.mp4 

- curl -I -H "Host: parcial.empresa.local" -H "Accept-Encoding: gzip" http://127.0.0.1/app.js 

- curl -I -H "Host: parcial.empresa.local" -H "Accept-Encoding: br" http://127.0.0.1/app.js 

- sudo bash /vagrant/parte2-apache/scripts/medir_compresion.sh 

#### **16. Nota sobre la sustentación** 

La guía del parcial establece que la evaluación es principalmente una demostración en vivo y que los scripts y archivos de configuración resultantes deben estar en GitHub. Este documento sirve como respaldo y organización de las evidencias, pero no sustituye la demostración solicitada por el docente. 

Informe actualizado — septiembre de 2026 

