#!/usr/bin/env bash
# Descarga a la carpeta img/ los fotogramas listados en images.txt.
# Solo baja los que aún no existen, así que se puede ejecutar cuantas veces haga falta.
set -uo pipefail
fail=0
while read -r path url; do
  [[ -z "${path:-}" || "$path" == \#* ]] && continue
  [[ -f "$path" ]] && continue
  mkdir -p "$(dirname "$path")"
  tmp="$(mktemp)"
  if [[ "$url" == *.mp4#t=* ]]; then
    t="${url##*#t=}"
    ffmpeg -loglevel error -y -ss "$t" -i "${url%#t=*}" -frames:v 1 -vf "scale=1920:-2" -q:v 3 "$path" || { echo "FALLO $path"; fail=1; }
    continue
  fi
  if ! curl -fsSL --retry 3 "$url" -o "$tmp"; then echo "FALLO $path"; fail=1; rm -f "$tmp"; continue; fi
  if file "$tmp" | grep -qi 'png\|webp'; then
    ffmpeg -loglevel error -y -i "$tmp" -q:v 2 "$path" || { echo "FALLO $path"; fail=1; }
  else
    mv "$tmp" "$path"
  fi
  rm -f "$tmp"
  echo "ok $path"
done < images.txt
# Imagen para compartir el enlace (1200x630) a partir de la portada
if [[ -f img/portada.jpg && ! -f img/og.jpg ]]; then
  ffmpeg -loglevel error -y -i img/portada.jpg -vf "scale=1200:630:force_original_aspect_ratio=increase,crop=1200:630" -q:v 3 img/og.jpg && echo "ok img/og.jpg"
fi
exit $fail
