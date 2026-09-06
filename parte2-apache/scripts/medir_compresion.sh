#!/usr/bin/env bash
# Ejecutar dentro de la VM web con sudo.
set -euo pipefail
BASE=/vagrant/parte2-apache
URL=http://parcial.empresa.local
RESULTADOS="$BASE/resultados"
RECURSOS=(index.html estilos.css app.js datos.json grafico.svg feed.xml lorem.txt)
mkdir -p "$RESULTADOS"
[ "$(id -u)" -eq 0 ] || { echo "Ejecute con sudo."; exit 1; }
getent hosts parcial.empresa.local >/dev/null || { echo "DNS no resuelve parcial.empresa.local"; exit 1; }
curl --noproxy '*' -fsSI "$URL/" >/dev/null
apache2ctl configtest
printf 'recurso,mime,algoritmo,nivel_calidad,tamano_original_bytes,tamano_transferido_bytes,ratio,ahorro_porcentaje,tiempo_segundos,cpu_curl_usuario_segundos,content_encoding\n' > "$RESULTADOS/resultados.csv"
mime(){ case "$1" in *.html) echo text/html;; *.css) echo text/css;; *.js) echo application/javascript;; *.json) echo application/json;; *.svg) echo image/svg+xml;; *.xml) echo text/xml;; *) echo text/plain;; esac; }
medir(){ local recurso=$1 algoritmo=$2 nivel=$3 encoding=$4 base=$5 cabecera salida cpu size tiempo codigo ce ratio ahorro; cabecera=$(mktemp); salida=$(mktemp); cpu=$(mktemp); /usr/bin/time -f '%U' -o "$cpu" curl --noproxy '*' -sS -H "Accept-Encoding: $encoding" -D "$cabecera" -o /dev/null -w '%{size_download};%{time_total};%{http_code}' "$URL/$recurso" >"$salida"; IFS=';' read -r size tiempo codigo <"$salida" || true; ce=$(awk -F': *' 'tolower($1)=="content-encoding" {gsub("\\r", "", $2); print tolower($2)}' "$cabecera" | tail -1); [ "$codigo" = 200 ] || { echo "HTTP $codigo en $recurso" >&2; exit 1; }; ratio=$(awk -v a="$size" -v b="$base" 'BEGIN{printf "%.6f",a/b}'); ahorro=$(awk -v r="$ratio" 'BEGIN{printf "%.3f",(1-r)*100}'); printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "$recurso" "$(mime "$recurso")" "$algoritmo" "$nivel" "$base" "$size" "$ratio" "$ahorro" "$tiempo" "$(cat "$cpu")" "${ce:-identity}" >> "$RESULTADOS/resultados.csv"; rm -f "$cabecera" "$salida" "$cpu"; }
configurar(){ local archivo=$1 directiva=$2 valor=$3; sed -Ei "s/^([[:space:]]*$directiva)[[:space:]]+[0-9]+/\\1 $valor/" "$archivo"; apache2ctl configtest >/dev/null; systemctl reload apache2; }
for r in "${RECURSOS[@]}"; do base=$(curl --noproxy '*' -sS -H 'Accept-Encoding: identity' -o /dev/null -w '%{size_download}' "$URL/$r"); medir "$r" identity base identity "$base"; done
for nivel in 1 6 9; do configurar /etc/apache2/conf-available/parte2-deflate.conf DeflateCompressionLevel "$nivel"; for r in "${RECURSOS[@]}"; do base=$(awk -F, -v r="$r" '$1==r && $3=="identity" {print $5; exit}' "$RESULTADOS/resultados.csv"); medir "$r" gzip "$nivel" gzip "$base"; done; done
for calidad in 5 11; do configurar /etc/apache2/conf-available/parte2-brotli.conf BrotliCompressionQuality "$calidad"; for r in "${RECURSOS[@]}"; do base=$(awk -F, -v r="$r" '$1==r && $3=="identity" {print $5; exit}' "$RESULTADOS/resultados.csv"); medir "$r" brotli "$calidad" br "$base"; done; done
{ echo '# Resultados reales'; echo; echo 'Generado por `medir_compresion.sh` contra Apache. `cpu_curl_usuario_segundos` es el CPU del cliente curl; la latencia incluye el procesamiento en el servidor.'; echo; echo '| Recurso | Algoritmo | Nivel | Original B | Transferido B | Ratio | Ahorro % | Tiempo s | CPU curl s | Content-Encoding |'; echo '|---|---|---:|---:|---:|---:|---:|---:|---:|---|'; tail -n +2 "$RESULTADOS/resultados.csv" | awk -F, '{printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n",$1,$3,$4,$5,$6,$7,$8,$9,$10,$11}'; } > "$RESULTADOS/resultados.md"
echo "Resultados reales: $RESULTADOS/resultados.csv"

