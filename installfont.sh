#!/bin/bash

fontName=$1
fontPath=$2

# Цветовые коды для вывода в терминале
PURPLE="\033[36m"
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

function color_echo() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${RESET}"
}

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
    color_echo "$GREEN" "Распаковка файла $fontPath..."
    if ! sudo unzip "$fontPath" -d "/usr/share/fonts/$fontName" > /dev/null; then
        color_echo "$RED" "Ошибка при распаковке архива $fontPath."
        exit 1
    fi
}

if [[ "$fontName" =~ \-\-help ]]; then 
    color_echo "$PURPLE" "Команда: $0 FontName ZipFilePath"
    echo "arg(FontName) - имя шрифта, arg(zipFilePath) - путь к zip файлу"
    exit 0
fi

if [[ -z "$fontName" || -z "$fontPath" ]]; then 
    color_echo "$RED" "Ошибка: требуется два аргумента: FontName и ZipFilePath."
    exit 1
fi

if [[ ! -f "$fontPath" ]]; then
    color_echo "$RED" "Ошибка: файл $fontPath не существует."
    exit 1
fi

if [[ "$fontPath" =~ \.zip$ ]]; then 
    unzipfile
    timeline "Установка шрифтов"
  
    fc-cache -fv > /dev/null
    timeline "Обновление кэша"
  
    color_echo "$GREEN" "Успех: шрифт $fontName установлен."
  
    color_echo "$PURPLE" "Лист файлов шрифта:"
    color_echo "$RED" "$(ls -1 /usr/share/fonts/$fontName)"
  
    color_echo "$GREEN" "Код: 0"
else
    color_echo "$RED" "Ошибка: поддерживаются только файлы .zip."
    color_echo "$RED" "Код: 1"
    exit 1
fi
