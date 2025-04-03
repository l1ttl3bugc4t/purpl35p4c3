#!/bin/bash
# ┌────────────────────────────────────────────────────────────┐
# │  🐾 purpl35p4c3 • web scanner automágico by l1ttl3bugc4t 💜 │
# │  script: auto_tools_check.sh                               │
# │  desc: nuclei, nikto y gowitness en modo adorablemente letal │
# └────────────────────────────────────────────────────────────┘

#!/bin/bash

# Script para pruebas automáticas con nuclei, nikto y gowitness
# Elaborado por Respuesta y Recuperación 🛡️

if [ "$#" -lt 1 ]; then
  echo "Uso: $0 <sitio1> [sitio2 sitio3 ...]"
  exit 1
fi

SITES=("$@")
DATE=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="auto_tools_results_$DATE"
mkdir -p "$RESULTS_DIR"

# Verificar si nuclei, nikto, gowitness están instalados
function check_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[!] La herramienta '$1' no está instalada o en el PATH." >&2
    return 1
  }
}

check_tool nuclei
check_tool nikto
check_tool gowitness

echo "[+] Ejecutando herramientas automáticas sobre: ${SITES[*]}"
echo "Resultados guardados en: $RESULTS_DIR"

for SITE in "${SITES[@]}"; do
  echo "------------------------------------------------------"
  echo "[*] Escaneando $SITE ..."
  SITE_DIR="$RESULTS_DIR/$(echo $SITE | sed 's|https\?://||;s|/|-|g')"
  mkdir -p "$SITE_DIR"

  # 1. nuclei
  echo "[+] nuclei en $SITE"
  nuclei -u "$SITE" -silent -o "$SITE_DIR/nuclei.txt" 2>/dev/null

  # 2. nikto
  echo "[+] nikto en $SITE"
  nikto -host "$SITE" -output "$SITE_DIR/nikto.txt" > /dev/null

  # 3. gowitness
  echo "[+] gowitness en $SITE"
  echo "$SITE" > "$SITE_DIR/gowitness_list.txt"
  gowitness single --url "$SITE" --destination "$SITE_DIR" --no-http

  echo "[*] Resultados para $SITE guardados en $SITE_DIR"
done

echo "[+] Análisis completo. Revisa los resultados en '$RESULTS_DIR'"

