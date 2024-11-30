#!/bin/bash

fontName=$1
fontPath=$2

PURPLE="\033[36m"
RED="\033[35m"
GREEN="\033[34m"  
RESET="\033[0m" 

function timeline() {
  for i in {1..30}; do
    progress=$((i * 1))

    str=" "
    for ((j=0; j<progress; j++)); do
      if ((RANDOM % 2 == 0)); then
        str="${str}0 "
      else
        str="${str}1 "
      fi
    done

    str="${str%" "}"

    fill=$(printf "  %.0s" $(seq $progress 30 ))
    
    res=$((progress * 3 + 10))
   
    echo -ne "\r${PURPLE}$1: ${RESET} ${GREEN}$res% ${RESET} [$str$fill]"

    sleep 0.02
  done
  echo  
}

function unzipfile() {
  if ! sudo unzip "$fontPath" -d "/usr/share/fonts/$fontName" > /dev/null; then
    echo "Ошибка при распаковке архива $fontPath."
    exit 1
  fi
}

if [[ "$fontName" =~ \-\-help ]]; then 
  echo "command arg(FontName) arg(zipFilePath)"
  exit 0
fi

if [[ -z "$fontName" || -z "$fontPath" ]]; then 
  echo "Ошибка: требуется два аргумента: FontName и ZipFilePath."
  exit 1
fi

if [[ ! -f "$fontPath" ]]; then
  echo "Ошибка: файл $fontPath не существует."
  exit 1
fi

if [[ "$fontPath" =~ \.zip$ ]]; then 
  unzipfile
  timeline "Устанновка шрифтов: "
  fc-cache -fv > /dev/null
  timeline "Обновленние кэша: "
  echo "Успех: шрифт $fontName установлен."
  echo "Лист: "
  echo -ne "${RED}$(ls /usr/share/fonts/${fontName})${RESET}"
  echo
  echo -ne "Код: ${GREEN}0${RESET}"
else
  echo "Ошибка: поддерживаются только файлы .zip"
  echo -ne "${RED}Код: 1${RESET}"
  exit 1
fi
