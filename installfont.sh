
#!/bin/bash
fontName=$1
fontPath=$2
deleteAnyWay=$3
snapShot="1"
codeResult="1"

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
PURPLE="\033[36m"

function color_echo() {
    local color=$1
    local message=$2
    echo -en "\r${color}${message}${RESET}"
}

# Параметры командной строки
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

function show_progress() {
    local task=$1
    local current=$2
    local total=$3
    local percent=$(( (current * 100) / total ))
    local str=" "
    local fill=""

    for ((i = 0; i < current; i++)); do
        if ((RANDOM % 2 == 0)); then
            str="${str}0 "
        else
            str="${str}1 "
        fi
    done

    fill=$(printf "  %.0s" $(seq $current $total))
    
    # Очистка строки и вывод прогресса
    echo -ne "\r${PURPLE}$task ${RESET} ${GREEN}$percent% ${RESET} [$str$fill]"
}

function SnapShot() {
    local status=$1

    if [[ ${status} == "1" ]]; then
        sudo cp -r /usr/share/fonts/${fontName} /usr/share/fonts/${fontName}snapShot
        snapShot="1"
    elif [[ ${status} == "0" ]]; then
        sudo rm -rf /usr/share/fonts/${fontName}snapShot
        snapShot="0"
    elif [[ ${status} == "2" ]]; then
        if [[ -d /usr/share/fonts/${fontName}snapShot ]]; then
            sudo rm -rf /usr/share/fonts/${fontName}
            sudo mv /usr/share/fonts/${fontName}snapShot /usr/share/fonts/${fontName}
            sudo rm -rf /usr/share/fonts/${fontName}snapShot
            snapShot="0"
        else
            color_echo "${RED}" "Упсссс.. Снепшота не существует <3"
            exit 1
        fi
    else 
        color_echo "${RED}" "Не удалось сделать SnapShot!"
        exit 1
    fi
}

function unzipfile() {
    if [ -d /usr/share/fonts/${fontName} ]; then 
        color_echo "${RED}" "Шрифт с таким названием уже существует. Перезаписать? Y/n: "
        read -r replace
        if [[ -z "${replace}" || "${replace}" == "Y" || "${replace}" == "y" ]]; then 
            SnapShot "1" 
            for i in {1..30}; do
                show_progress "Создание снимка" $i 30
                sleep 0.02
            done
            sudo rm -rf /usr/share/fonts/${fontName}
            if ! sudo unzip "$fontPath" -d "/usr/share/fonts/$fontName" > /dev/null; then
                color_echo "$RED" "Ошибка при распаковке архива $fontPath."
                exit 1
            fi
        elif [[ "${replace}" == "N" || "${replace}" == "n" ]]; then
            color_echo "$GREEN" "Отмена операции"
            exit 1
        fi
    else
        if ! sudo unzip "$fontPath" -d "/usr/share/fonts/$fontName" > /dev/null; then
            color_echo "$RED" "Ошибка при распаковке архива $fontPath."
            exit 1
        fi
    fi
}

function clearDirectory() {
    sudo find /usr/share/fonts/${fontName} -type f -exec mv {} /usr/share/fonts/${fontName}/ \; > /dev/null 2>&1
    sudo find /usr/share/fonts/${fontName} -type d -empty -delete > /dev/null
    sudo rm -rf /usr/share/fonts/${fontName}/*.txt || sudo rm -rf /usr/share/fonts/${fontName}/*.md
}

function deleteZipFile() {
    if [[ "$fontPath" =~ ^/ ]]; then
        zipFilePath="$fontPath"
    else
        zipFilePath="$(pwd)/$fontPath"
    fi
    if [[ "$zipFilePath" =~ \.zip$ && -f "$zipFilePath" ]]; then
        rm "$zipFilePath"
        if [[ ! -f "$zipFilePath" ]]; then
            color_echo "$GREEN" "Файл успешно удален!"
        else
            color_echo "$RED" "Не удалось удалить файл!" 
        fi
    else
        color_echo "$RED" "Невозможно удалить файл! Небезопасно"
    fi
}

checkFile () {
    if  find /usr/share/fonts/${fontName} -type f -print -quit | grep -q . > /dev/null; then
        codeResult="0"
    else 
        SnapShot "2"
        codeResult="1"
        color_echo "${RED}" "Не удалось установить шрифт ${fontName}, Бэкап вашего шрифта был сохранен и восстановлен!"
        exit 1
    fi
}

function install_font() {
    unzipfile
    for i in {1..30}; do
        show_progress "Распаковка шрифта" $i 30
        sleep 0.02
    done 
    
    for i in {1..30}; do
        show_progress "Проверка файлов..." $i 30
        sleep 0.02
    done
    checkFile

    if [ -d "/usr/share/fonts/${fontName}" ]; then
        if find "/usr/share/fonts/${fontName}" -mindepth 1 -maxdepth 1 -type d | read; then
            clearDirectory
            for i in {1..30}; do
                show_progress "Удаление мусора..." $i 30
                sleep 0.02
            done
        else 
            sudo rm -rf /usr/share/fonts/${fontName}/*.txt 
        fi
    fi    

    for i in {1..30}; do
        show_progress "Проверка файлов..." $i 30
        sleep 0.02
    done
    checkFile

    fc-cache -fv > /dev/null
    for i in {1..30}; do
        show_progress "Обновление кэша..." $i 30
        sleep 0.02
    done

    if [[ "${codeResult}" == "0" ]]; then
        color_echo "${GREEN}" "\rШрифт ${fontName} установлен.                                                                                                                                                                                                         \n"
        color_echo "${PURPLE}" "\r$(ls /usr/share/fonts/${fontName})"
        SnapShot "0"
    else
        color_echo "${RED}" "\rНе удалось установить шрифт!"
    fi
}

# Точка входа
if [[ "$fontPath" =~ \.zip$ ]]; then 
    install_font

    if [[ "$deleteAnyWay" =~ \-d || "$deleteAnyWay" =~ \-\-delete ]]; then
        deleteZipFile
    else
        color_echo "$RED" "\rУдалить исходный zip архив y/N?: "
        read -r deleteZip
        if [[ "${deleteZip}" == "Y" || "${deleteZip}" == "y" ]]; then 
            deleteZipFile
        elif [[ -z "${deleteZip}" || "${deleteZip}" == "N" || "${deleteZip}" == "n" ]]; then
            color_echo "$GREEN" "Файл не будет удален."
        fi
    fi
else
    color_echo "$RED" "Ошибка: поддерживаются только файлы .zip."
    color_echo "$RED" "Код: 1"
    exit 1
fi

color_echo "$GREEN" "Код: 0"
