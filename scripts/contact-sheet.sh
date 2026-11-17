#!/usr/bin/env bash
# Hoja de contactos: un fotograma cada pocos segundos, numerado con su segundo.
set -uo pipefail
mkdir -p hojas
font=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
sheet(){ name="$1"; url="$2"; step="$3"
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$url" | cut -d. -f1)
  tmp=$(mktemp -d); i=0
  for ((t=1; t<dur; t+=step)); do
    i=$((i+1))
    ffmpeg -loglevel error -y -ss "$t" -i "$url" -frames:v 1 \
      -vf "scale=384:-2,drawtext=fontfile=$font:text='${t}s':x=10:y=10:fontsize=26:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6" \
      "$tmp/$(printf %03d $i).jpg"
  done
  ffmpeg -loglevel error -y -framerate 1 -i "$tmp/%03d.jpg" -vf "tile=5x$(( (i+4)/5 )):padding=6:color=white" -frames:v 1 -q:v 3 "hojas/$name.jpg"
  echo "ok $name ($i fotogramas)"
}
sheet epistrophe-card07 "https://epistrophemagazine.com/wp-content/uploads/2024/06/georgia.mp4" 4
sheet epistrophe-card08 "https://epistrophemagazine.com/wp-content/uploads/2024/06/rebecca-corrigido.mp4" 4
