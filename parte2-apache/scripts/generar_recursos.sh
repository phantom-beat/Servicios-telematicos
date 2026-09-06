#!/usr/bin/env bash
# Genera recursos deterministas y suficientemente grandes para medir compresion.
set -euo pipefail
DESTINO="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../sitio" && pwd)}"
mkdir -p "$DESTINO"
python3 - "$DESTINO" <<'PY'
import base64, json, sys, zipfile
from pathlib import Path
root = Path(sys.argv[1]); root.mkdir(parents=True, exist_ok=True)
cards = [f'<article class="card card-{n % 24}"><h2>Servicio telematico {n}</h2><p>Metricas de red, disponibilidad, latencia y transferencia para la demostracion de compresion HTTP.</p></article>' for n in range(1, 1101)]
(root/'index.html').write_text('<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Parte 2 - Compresion Apache</title><link rel="stylesheet" href="estilos.css"></head><body><main><h1>Comparacion gzip y Brotli</h1>'+''.join(cards)+'</main><script src="app.js"></script></body></html>', encoding='utf-8')
css=['body{font-family:system-ui;margin:2rem;background:#f5f7fb;color:#172033}.card{padding:1rem;margin:.5rem;background:#fff;border-radius:.5rem}']+[f'.card-{i}'+'{border-left:4px solid hsl('+str(i*15)+',70%,45%);padding:'+str(8+i)+'px;margin:'+str(i%9)+'px}' for i in range(24)]*180
(root/'estilos.css').write_text('\n'.join(css), encoding='utf-8')
js=['const metricas=[];']+[f'metricas.push({{id:{i},servicio:"telemetria",estado:"estable",latenciaMs:{10+i%91},mensaje:"Muestra repetible para evaluar compresion de JavaScript"}});' for i in range(4200)]+['document.documentElement.dataset.metricas=metricas.length;']
(root/'app.js').write_text('\n'.join(js), encoding='utf-8')
datos=[{"id":i,"dispositivo":f"sensor-{i:05d}","zona":f"zona-{i%20}","estado":"operativo","mensaje":"Registro de telemetria repetible para evaluar compresion JSON","latencia_ms":12+i%80} for i in range(13000)]
(root/'datos.json').write_text(json.dumps(datos,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
circles=''.join(f'<circle cx="{(i*37)%1200}" cy="{(i*61)%700}" r="{4+i%17}" class="p{i%8}"/>' for i in range(4200))
(root/'grafico.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 700"><style>.p0{fill:#155}.p1{fill:#287}.p2{fill:#4a9}.p3{fill:#7bc}</style>'+circles+'</svg>',encoding='utf-8')
items=''.join(f'<item><title>Evento {i}</title><description>Evento repetible de red para medicion de XML y compresion HTTP.</description><guid>{i}</guid></item>' for i in range(3500))
(root/'feed.xml').write_text('<?xml version="1.0"?><rss version="2.0"><channel><title>Telemetria</title>'+items+'</channel></rss>',encoding='utf-8')
paragraph='La red de servicios telematicos registra disponibilidad, latencia y trafico. Este texto reproducible permite observar el efecto de la compresion HTTP sobre contenido altamente redundante.\n'
(root/'lorem.txt').write_text(paragraph*10000,encoding='utf-8')
(root/'imagen.png').write_bytes(base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL9WQAAAABJRU5ErkJggg=='))
(root/'foto.jpg').write_bytes(base64.b64decode('/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAF//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABBQJ//8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAgBAwEBPwF//8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAgBAgEBPwF//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQAGPwJ//8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPyF//9k='))
with zipfile.ZipFile(root/'paquete.zip','w',zipfile.ZIP_DEFLATED) as z: z.writestr('telemetria.txt',paragraph*500)
PY
printf 'Recursos generados en %s\n' "$DESTINO"
