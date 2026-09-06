# Resultados reales

Generado por `medir_compresion.sh` contra Apache. `cpu_curl_usuario_segundos` es el CPU del cliente curl; la latencia incluye el procesamiento en el servidor.

| Recurso | Algoritmo | Nivel | Original B | Transferido B | Ratio | Ahorro % | Tiempo s | CPU curl s | Content-Encoding |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| index.html | identity | base | 194481 | 194481 | 1.000000 | 0.000 | 0.009383 | 0.01 | identity |
| estilos.css | identity | base | 311900 | 311900 | 1.000000 | 0.000 | 0.029649 | 0.01 | identity |
| app.js | identity | base | 608013 | 608013 | 1.000000 | 0.000 | 0.007844 | 0.01 | identity |
| datos.json | identity | base | 2205391 | 2205391 | 1.000000 | 0.000 | 0.014180 | 0.01 | identity |
| grafico.svg | identity | base | 187306 | 187306 | 1.000000 | 0.000 | 0.009092 | 0.01 | identity |
| feed.xml | identity | base | 508870 | 508870 | 1.000000 | 0.000 | 0.032859 | 0.02 | identity |
| lorem.txt | identity | base | 1880000 | 1880000 | 1.000000 | 0.000 | 0.010241 | 0.01 | identity |
| index.html | gzip | 1 | 194481 | 5939 | 0.030538 | 96.946 | 0.009351 | 0.00 | gzip |
| estilos.css | gzip | 1 | 311900 | 6308 | 0.020224 | 97.978 | 0.012725 | 0.03 | gzip |
| app.js | gzip | 1 | 608013 | 22909 | 0.037678 | 96.232 | 0.010729 | 0.01 | gzip |
| datos.json | gzip | 1 | 2205391 | 134477 | 0.060976 | 93.902 | 0.032801 | 0.02 | gzip |
| grafico.svg | gzip | 1 | 187306 | 42099 | 0.224761 | 77.524 | 0.014081 | 0.02 | gzip |
| feed.xml | gzip | 1 | 508870 | 21033 | 0.041333 | 95.867 | 0.015353 | 0.01 | gzip |
| lorem.txt | gzip | 1 | 1880000 | 13454 | 0.007156 | 99.284 | 0.026043 | 0.01 | gzip |
| index.html | gzip | 6 | 194481 | 5692 | 0.029268 | 97.073 | 0.013375 | 0.01 | gzip |
| estilos.css | gzip | 6 | 311900 | 2091 | 0.006704 | 99.330 | 0.011677 | 0.01 | gzip |
| app.js | gzip | 6 | 608013 | 21617 | 0.035554 | 96.445 | 0.025231 | 0.02 | gzip |
| datos.json | gzip | 6 | 2205391 | 108117 | 0.049024 | 95.098 | 0.060713 | 0.01 | gzip |
| grafico.svg | gzip | 6 | 187306 | 24035 | 0.128319 | 87.168 | 0.032184 | 0.02 | gzip |
| feed.xml | gzip | 6 | 508870 | 20349 | 0.039989 | 96.001 | 0.016264 | 0.01 | gzip |
| lorem.txt | gzip | 6 | 1880000 | 7470 | 0.003973 | 99.603 | 0.037509 | 0.01 | gzip |
| index.html | gzip | 9 | 194481 | 4525 | 0.023267 | 97.673 | 0.015207 | 0.00 | gzip |
| estilos.css | gzip | 9 | 311900 | 2090 | 0.006701 | 99.330 | 0.011367 | 0.01 | gzip |
| app.js | gzip | 9 | 608013 | 21370 | 0.035147 | 96.485 | 0.026548 | 0.02 | gzip |
| datos.json | gzip | 9 | 2205391 | 84454 | 0.038294 | 96.171 | 0.251345 | 0.01 | gzip |
| grafico.svg | gzip | 9 | 187306 | 22038 | 0.117658 | 88.234 | 0.087877 | 0.02 | gzip |
| feed.xml | gzip | 9 | 508870 | 20043 | 0.039387 | 96.061 | 0.026727 | 0.02 | gzip |
| lorem.txt | gzip | 9 | 1880000 | 7470 | 0.003973 | 99.603 | 0.062479 | 0.02 | gzip |
| index.html | brotli | 5 | 194481 | 2579 | 0.013261 | 98.674 | 0.014147 | 0.01 | br |
| estilos.css | brotli | 5 | 311900 | 291 | 0.000933 | 99.907 | 0.022225 | 0.01 | br |
| app.js | brotli | 5 | 608013 | 9304 | 0.015302 | 98.470 | 0.020014 | 0.01 | br |
| datos.json | brotli | 5 | 2205391 | 34728 | 0.015747 | 98.425 | 0.080083 | 0.01 | br |
| grafico.svg | brotli | 5 | 187306 | 15928 | 0.085037 | 91.496 | 0.020982 | 0.01 | br |
| feed.xml | brotli | 5 | 508870 | 7568 | 0.014872 | 98.513 | 0.021068 | 0.01 | br |
| lorem.txt | brotli | 5 | 1880000 | 187 | 0.000099 | 99.990 | 0.021941 | 0.02 | br |
| index.html | brotli | 11 | 194481 | 3412 | 0.017544 | 98.246 | 1.287300 | 0.01 | br |
| estilos.css | brotli | 11 | 311900 | 270 | 0.000866 | 99.913 | 0.085228 | 0.02 | br |
| app.js | brotli | 11 | 608013 | 8693 | 0.014297 | 98.570 | 4.370670 | 0.00 | br |
| datos.json | brotli | 11 | 2205391 | 37147 | 0.016844 | 98.316 | 17.196073 | 0.01 | br |
| grafico.svg | brotli | 11 | 187306 | 10319 | 0.055092 | 94.491 | 0.931898 | 0.02 | br |
| feed.xml | brotli | 11 | 508870 | 6325 | 0.012430 | 98.757 | 3.248751 | 0.01 | br |
| lorem.txt | brotli | 11 | 1880000 | 132 | 0.000070 | 99.993 | 0.092627 | 0.01 | br |
