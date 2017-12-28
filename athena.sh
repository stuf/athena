#!/usr/bin/env bash
set -e

source .scriptrc

# Core

WORK_DIR="$(pwd)/work"
LOG_DIR="$(pwd)/logs"
LOG_FILE="$LOG_DIR/athena.log"

# Data

DATA_DIR="$(pwd)/data"
SCAN_DIR="$DATA_DIR/scan"
DB_DIR="$DATA_DIR/db"
OCR_DIR="$DATA_DIR/ocr"

#

setup() {
  # Directories
  dirs=( "$WORK_DIR" "$LOG_DIR" "$DATA_DIR" "$SCAN_DIR" "$DB_DIR" "$OCR_DIR" )
  files=( "$LOG_FILE" )

  for dir in ${dirs[@]}; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir"
  done

  # Individual files
  for file in ${files[@]}; do
    [[ ! -f "$file" ]] && touch "$file"
  done

  return 0
}

#

log() {
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$timestamp] $1"
  echo "[$timestamp] $1" >> "$LOG_FILE"
}

#

scan_image() {
  DPI=300
  MODE="Color"
  FORMAT="pnm"
  FILE=$(date -u +"%Y%m%d-%H%M%S")

  scanimage --resolution $DPI >"$SCAN_DIR/$FILE"
}

ocr_image() {
  IN="$1"

  local IN_FILE="$(basename "$IN")"
  local IN_FILE_BASE="$(basename "$IN" .pnm)"
  local TASK_DIR="$WORK_DIR/$IN_FILE"
  local TASK_FILE="$TASK_DIR/$IN_FILE"
  local cmd="cd /home/work/$IN_FILE && tesseract "./$IN_FILE" "$IN_FILE_BASE" -l eng --psm 1 --oem 2 txt pdf hocr"

  if [[ ! -f "$IN" ]]; then
    log "INFILE ($IN) does not exist."
    exit 1
  fi

  mkdir -p "$TASK_DIR"

  log "Copying data to workdir $TASK_DIR"
  cp "$IN" "$TASK_DIR"

  log "Running Tesseract on image with: $cmd"
  docker exec -i --tty=false "t4re" /bin/bash -c "$cmd"

  log "Removing image from workdir $TASK_DIR"
  rm $TASK_FILE

  log "Copying results from $TASK_DIR to $OCR_DIR"
  cp -fr "$TASK_DIR" "$OCR_DIR"

  log "Done."
}

#

setup

#

case "$1" in
  start)
    docker run -dt -v "$WORK_DIR:/home/work" --name "$TESSERACT_NAME" "$TESSERACT_CONTAINER"
    ;;
  startdb)
    rethinkdb \
      --bind all \
      --directory "$DB_DIR" \
      --log-file "$LOG_DIR/rdblog"
    ;;
  scan)
    log "Scanning image"
    log "Not implemented yet"
    exit 1
    ;;
  ocr)
    ocr_image "$2"
    ;;
  *)
    echo "usage: $0 [start | startdb | scan | ocr]"
    exit 1
esac

exit 0
