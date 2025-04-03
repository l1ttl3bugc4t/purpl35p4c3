#!/bin/bash
# ┌────────────────────────────────────────────────────────────┐
# │  🐾 purpl35p4c3 • reconnaissance tool by l1ttl3bugc4t 💜     │
# │  script: cat-recon.sh                                      │
# │  desc: multi-phase recon with claws, pings and purrrs 🐱     │
# └────────────────────────────────────────────────────────────┘

# 🐾 Verifica argumentos
if [ -z "$1" ]; then
  echo "🌸 Uso correcto: $0 <IP>"
  exit 1
fi

# 🧶 Verifica herramientas necesarias
for cmd in nmap whois nslookup ping traceroute; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Error: '$cmd' no está instalado. Abortando misión gatuna."
    exit 1
  fi
done

# ☁️ Variables iniciales
IP=$1
OUTPUT_DIR="recon_$IP"
mkdir -p "$OUTPUT_DIR"

echo "🐾 Iniciando escaneo mimoso para: $IP"
echo "📂 Resultados en: $OUTPUT_DIR/"

DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "$DATE" > "$OUTPUT_DIR/timestamp.txt"

# 🐾 Información general
echo "💌 Enviando ping de cariño..."
ping -c 4 "$IP" > "$OUTPUT_DIR/ping.txt"

echo "📇 Obteniendo datos con whois..."
whois "$IP" > "$OUTPUT_DIR/whois.txt"

echo "🧭 Haciendo nslookup..."
nslookup "$IP" > "$OUTPUT_DIR/nslookup.txt"

echo "🚀 Lanzando traceroute interestelar..."
traceroute "$IP" > "$OUTPUT_DIR/traceroute.txt"

# 🐾 FASE 1 - Descubrimiento de puertos
echo "🛰️ FASE 1: Escaneo de puertos abiertos con Nmap..."
timeout 900s nmap -v -Pn -p- --min-rate=500 --max-retries=2 --open "$IP" -oG "$OUTPUT_DIR/nmap_ports.gnmap"

if [ $? -eq 124 ]; then
  echo "⚠️ El escaneo fue interrumpido por tiempo límite (15 min)."
fi

# 🐾 Extracción de puertos
PORTS=$(grep "Ports:" "$OUTPUT_DIR/nmap_ports.gnmap" | \
        grep -oP '\\d+/open' | \
        cut -d/ -f1 | \
        sort -n | uniq | paste -sd, -)

if [ -z "$PORTS" ]; then
  echo "🫥 No se detectaron puertos abiertos."
  PORTS="none"
else
  echo "😼 Puertos abiertos detectados: $PORTS"
fi

# 🐾 FASE 2 - Identificación de servicios y sistema
if [ "$PORTS" != "none" ]; then
  echo "🔍 FASE 2: Detección de servicios y sistema operativo..."
  timeout 1800s nmap -v -Pn -sV -O -p"$PORTS" "$IP" -oN "$OUTPUT_DIR/nmap_deteccion.txt"

  if [ $? -eq 124 ]; then
    echo "⚠️ Nmap fue interrumpido (30 min)..." >> "$OUTPUT_DIR/nmap_deteccion.txt"
  fi
else
  echo "😿 No se ejecutó la detección por falta de puertos."
fi

# 📝 Generar reporte
REPORT="$OUTPUT_DIR/reporte.txt"

{
  echo "========== 🐾 RECONOCIMIENTO DE IP 🐾 =========="
  echo "Dirección IP: $IP"
  echo "Fecha/Hora: $DATE"
  echo
  echo "------ 🫧 PING ------"
  grep -E 'packets transmitted|rtt' "$OUTPUT_DIR/ping.txt"
  echo
  echo "------ 📚 WHOIS ------"
  grep -Ei 'OrgName|organization|netname|descr' "$OUTPUT_DIR/whois.txt" | head -n 5
  echo
  echo "------ 🌐 NSLOOKUP ------"
  grep "name =" "$OUTPUT_DIR/nslookup.txt" || echo "No se resolvió nombre DNS."
  echo
  echo "------ 🚀 TRACEROUTE ------"
  head -n 2 "$OUTPUT_DIR/traceroute.txt"
  tail -n 2 "$OUTPUT_DIR/traceroute.txt"
  echo
  echo "------ 🚪 PUERTOS ABIERTOS ------"
  echo "$PORTS"
  echo
  echo "------ 🧠 SERVICIOS Y SISTEMA ------"
  if [ "$PORTS" != "none" ]; then
    grep -E '^[0-9]+/tcp' "$OUTPUT_DIR/nmap_deteccion.txt"
    grep -Ei 'Running:|OS details' "$OUTPUT_DIR/nmap_deteccion.txt" | head -n 5
    grep -i 'Nmap fue interrumpido' "$OUTPUT_DIR/nmap_deteccion.txt"
  else
    echo "Nmap no se ejecutó."
  fi
  echo
  echo "=============================================="
} > "$REPORT"

# ✨ Mostrar resultado
echo
echo "✅ Escaneo completo. Reporte generado en:"
echo "📄 $REPORT"
echo "🐈‍⬛ Fin de la misión felina 🐾"
