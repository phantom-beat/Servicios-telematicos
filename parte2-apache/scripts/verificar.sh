#!/usr/bin/env bash
# =============================================================
# verificar.sh — Script de verificación Parte 2 (Apache)
# Servicios Telemáticos — Parcial
#
# Ejecutar DENTRO de la VM web:
#   chmod +x /vagrant/parte2-apache/scripts/verificar.sh
#   sudo bash /vagrant/parte2-apache/scripts/verificar.sh
# =============================================================

set -euo pipefail

# ── Colores ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

PASS="${GREEN}[PASS]${NC}"
FAIL="${RED}[FAIL]${NC}"
INFO="${CYAN}[INFO]${NC}"
WARN="${YELLOW}[WARN]${NC}"

ERRORES=0

echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${BOLD}   VERIFICACIÓN PARTE 2 — Apache VirtualHosts${NC}"
echo -e "${BOLD}   Servicios Telemáticos — Parcial${NC}"
echo -e "${BOLD}============================================================${NC}"
echo ""

# ── 1. Estado de Apache ────────────────────────────────────────
echo -e "${BOLD}[1] Estado del servicio Apache2${NC}"
if systemctl is-active --quiet apache2; then
    echo -e "  $PASS apache2 está ACTIVO (running)"
else
    echo -e "  $FAIL apache2 NO está corriendo"
    ERRORES=$((ERRORES + 1))
fi

if systemctl is-enabled --quiet apache2; then
    echo -e "  $PASS apache2 habilitado para arranque automático"
else
    echo -e "  $WARN apache2 NO está habilitado en arranque"
fi
echo ""

# ── 2. Módulos habilitados ────────────────────────────────────
echo -e "${BOLD}[2] Módulos Apache requeridos${NC}"
for mod in rewrite headers; do
    if grep -q "${mod}_module" < <(apache2ctl -M 2>&1); then
        echo -e "  $PASS Módulo '${mod}' cargado"
    else
        echo -e "  $FAIL Módulo '${mod}' NO cargado"
        ERRORES=$((ERRORES + 1))
    fi
done
echo ""

# ── 3. Configuración de VirtualHosts ─────────────────────────
echo -e "${BOLD}[3] Configuración de VirtualHosts${NC}"
for site in www.empresa.local api.empresa.local; do
    if [ -f "/etc/apache2/sites-available/${site}.conf" ]; then
        echo -e "  $PASS Conf disponible: ${site}.conf"
    else
        echo -e "  $FAIL Conf NO encontrada: ${site}.conf"
        ERRORES=$((ERRORES + 1))
    fi

    if [ -L "/etc/apache2/sites-enabled/${site}.conf" ]; then
        echo -e "  $PASS Habilitado: ${site}"
    else
        echo -e "  $FAIL NO habilitado: ${site}"
        ERRORES=$((ERRORES + 1))
    fi
done

# Verificar que el default está deshabilitado
if [ ! -L "/etc/apache2/sites-enabled/000-default.conf" ]; then
    echo -e "  $PASS Sitio default (000-default) deshabilitado"
else
    echo -e "  $WARN Sitio default (000-default) todavía habilitado"
fi
echo ""

# ── 4. Document Roots ─────────────────────────────────────────
echo -e "${BOLD}[4] Document Roots y archivos${NC}"
declare -A ROOTS=(
    ["www.empresa.local"]="/var/www/www.empresa.local/html"
    ["api.empresa.local"]="/var/www/api.empresa.local/html"
)
for site in "${!ROOTS[@]}"; do
    root="${ROOTS[$site]}"
    if [ -d "$root" ]; then
        echo -e "  $PASS Directorio existe: $root"
    else
        echo -e "  $FAIL Directorio NO existe: $root"
        ERRORES=$((ERRORES + 1))
    fi

    if [ -f "$root/index.html" ]; then
        echo -e "  $PASS index.html presente en $site"
    else
        echo -e "  $WARN index.html NO encontrado en $root"
    fi
done
echo ""

# ── 5. Sintaxis de Apache ─────────────────────────────────────
echo -e "${BOLD}[5] Validación de sintaxis Apache${NC}"
if apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "  $PASS Sintaxis OK"
else
    echo -e "  $FAIL Error en sintaxis de configuración"
    apache2ctl configtest 2>&1 | grep -v "^$"
    ERRORES=$((ERRORES + 1))
fi
echo ""

# ── 6. Pruebas HTTP locales ───────────────────────────────────
echo -e "${BOLD}[6] Pruebas HTTP (curl localhost con Host header)${NC}"

# www.empresa.local
echo -e "  ${INFO} Probando www.empresa.local..."
HTTP_CODE=$(curl -s -o /tmp/resp_www.html -w "%{http_code}" \
    -H "Host: www.empresa.local" http://127.0.0.1/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  $PASS HTTP 200 — www.empresa.local responde correctamente"
    if grep -q "empresa.local" /tmp/resp_www.html 2>/dev/null; then
        echo -e "  $PASS Contenido correcto (contiene 'empresa.local')"
    else
        echo -e "  $WARN Respuesta no contiene 'empresa.local'"
    fi
else
    echo -e "  $FAIL HTTP ${HTTP_CODE} — www.empresa.local no responde (esperado 200)"
    ERRORES=$((ERRORES + 1))
fi

# api.empresa.local
echo -e "  ${INFO} Probando api.empresa.local..."
HTTP_CODE=$(curl -s -o /tmp/resp_api.html -w "%{http_code}" \
    -H "Host: api.empresa.local" http://127.0.0.1/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  $PASS HTTP 200 — api.empresa.local responde correctamente"
else
    echo -e "  $FAIL HTTP ${HTTP_CODE} — api.empresa.local no responde (esperado 200)"
    ERRORES=$((ERRORES + 1))
fi

# ftp alias (CNAME → www)
echo -e "  ${INFO} Probando ftp.empresa.local (CNAME alias)..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Host: ftp.empresa.local" http://127.0.0.1/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ]; then
    echo -e "  $PASS HTTP ${HTTP_CODE} — ftp alias funciona"
else
    echo -e "  $WARN HTTP ${HTTP_CODE} — ftp alias (puede no estar configurado aún)"
fi
echo ""

# ── 7. Resolución DNS ─────────────────────────────────────────
echo -e "${BOLD}[7] Resolución DNS (requiere VMs de Parte 1 activas)${NC}"
DNS_SERVER="192.168.50.2"
for host in www.empresa.local api.empresa.local mail.empresa.local; do
    RESULT=$(dig @${DNS_SERVER} +short A ${host} 2>/dev/null || echo "")
    if [ -n "$RESULT" ]; then
        echo -e "  $PASS ${host} → ${RESULT}"
    else
        echo -e "  $WARN ${host} → sin respuesta (¿está corriendo el DNS Maestro?)"
    fi
done

# Prueba inversa
echo -e "  ${INFO} Resolución inversa de 192.168.50.10..."
PTR=$(dig @${DNS_SERVER} +short -x 192.168.50.10 2>/dev/null || echo "")
if [ -n "$PTR" ]; then
    echo -e "  $PASS PTR → ${PTR}"
else
    echo -e "  $WARN Sin PTR (¿DNS activo?)"
fi
echo ""

# ── 8. Cabeceras de seguridad ─────────────────────────────────
echo -e "${BOLD}[8] Cabeceras de seguridad HTTP${NC}"
HEADERS=$(curl -sI -H "Host: www.empresa.local" http://127.0.0.1/ 2>/dev/null || echo "")
for header in "X-Content-Type-Options" "X-Frame-Options" "X-XSS-Protection"; do
    if echo "$HEADERS" | grep -qi "$header"; then
        echo -e "  $PASS Cabecera presente: ${header}"
    else
        echo -e "  $WARN Cabecera ausente: ${header}"
    fi
done
echo ""

# ── 9. Logs de Apache ─────────────────────────────────────────
echo -e "${BOLD}[9] Archivos de log${NC}"
for log in \
    "/var/log/apache2/www.empresa.local-access.log" \
    "/var/log/apache2/www.empresa.local-error.log"  \
    "/var/log/apache2/api.empresa.local-access.log" \
    "/var/log/apache2/api.empresa.local-error.log"; do
    if [ -f "$log" ]; then
        SIZE=$(du -sh "$log" 2>/dev/null | cut -f1)
        echo -e "  $PASS Existe: $(basename $log) (${SIZE})"
    else
        echo -e "  $INFO Pendiente: $(basename $log) (se crea con el primer request)"
    fi
done
echo ""

# ── 10. Compresión Parte 2 ───────────────────────────────────
echo -e "${BOLD}[10] Compresión y dominio parcial.empresa.local${NC}"
for mod in deflate brotli; do
    if grep -q "${mod}_module" < <(apache2ctl -M 2>&1); then echo -e "  $PASS Módulo '${mod}' cargado"; else echo -e "  $FAIL Módulo '${mod}' NO cargado"; ERRORES=$((ERRORES + 1)); fi
done
if dig @192.168.50.2 +short parcial.empresa.local 2>/dev/null | grep -qx '192.168.50.10'; then echo -e "  $PASS DNS parcial.empresa.local → 192.168.50.10"; else echo -e "  $WARN DNS parcial.empresa.local no responde (revise DNS Maestro)"; fi
for enc in 'identity:identity' 'gzip:gzip' 'br:br'; do
  solicitado=${enc%%:*}; esperado=${enc##*:}; h=$(curl --noproxy '*' -sSI -H "Accept-Encoding: $solicitado" http://127.0.0.1/app.js -H 'Host: parcial.empresa.local' || true)
  if [ "$esperado" = identity ]; then echo -e "  $PASS identity consultado"; elif echo "$h" | grep -qi "^Content-Encoding: $esperado"; then echo -e "  $PASS app.js usa $esperado"; else echo -e "  $FAIL app.js no usa $esperado"; ERRORES=$((ERRORES + 1)); fi
done
for archivo in foto.jpg imagen.png paquete.zip; do
  if curl --noproxy '*' -sSI -H 'Accept-Encoding: br,gzip' "http://127.0.0.1/$archivo" -H 'Host: parcial.empresa.local' | grep -qi '^Content-Encoding:'; then echo -e "  $FAIL $archivo fue recomprimido"; ERRORES=$((ERRORES + 1)); else echo -e "  $PASS $archivo sin Content-Encoding"; fi
done
echo ""
# ── Resultado final ───────────────────────────────────────────
echo -e "${BOLD}============================================================${NC}"
if [ "$ERRORES" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}  ✔  TODOS LOS CHECKS PASARON — Parte 2 operativa${NC}"
else
    echo -e "${RED}${BOLD}  ✘  ${ERRORES} ERROR(ES) encontrado(s) — revisar arriba${NC}"
fi
echo -e "${BOLD}============================================================${NC}"
echo ""

exit $ERRORES




