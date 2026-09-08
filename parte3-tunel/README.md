# Parte 3 — Túnel seguro

## Objetivo

Publicar el servidor Apache desarrollado en la Parte 2 mediante un túnel seguro, permitiendo acceder al servicio desde una red externa sin realizar redirección de puertos en el router.

## Infraestructura

- Máquina virtual: `apache.empresa.local`
- IP privada: `192.168.50.10`
- Servidor web: Apache 2.4.52
- VirtualHost: `parcial.empresa.local`
- Puerto local: `80`
- Servicio de túnel: Cloudflare Tunnel
- Modalidad: Quick Tunnel
- Acceso público: HTTPS

## Página personalizada

La página utilizada para la demostración es:

`pagina_personalizada.html`

La página contiene:

- Nombre: JOSE DAVID AGUIRRE
- Código: 2230633
- Nombre: GABRIEL ARMANDO GIL
- Código: 2230206
- Fecha: 8 de septiembre de 2026
- Identificador: PARCIAL-2026-01

## Configuración del túnel

Se utilizó Cloudflare Quick Tunnel mediante el siguiente comando:

```bash
cloudflared tunnel --url http://192.168.50.10:80 --http-host-header parcial.empresa.local
