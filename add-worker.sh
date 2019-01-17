#!/usr/bin/env bash

#colors
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

usage() {
    echo "Modo de uso: $0 [-i <string>] <string>" 1>&2; exit 1;
}
# script for arg: http://codedpoetry.com/shell-scripts-arguments/
# Loop over all the options with "getopts"
while getopts ":i:" option; do
    case "${option}" in
        i)
            i=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

# skip all the "opts" arguments and read the rest of the arguments. In this case
# we only read one string argument
shift $((OPTIND-1))
arg=$1

# Validate mandatory options and arguments
if [ -z "${i}" ] || [ -z "${arg}" ]; then
    usage
fi

#install requirements
tools_requirements=(python3 wget curl)
url_requirements="https://raw.githubusercontent.com/fabidick22/add-worker-DaskCluster/master/requirements.txt"
daskPath=~/daskCluster
envPath=~/virtualEnv

function echo_fail {
  # echo first argument in red
  printf "\e[31m✘ ${1} No Installed"
  # reset colours back to normal
  printf "\033[0m \n"
}

# display a message in green with a tick by it
# example
# echo echo_fail "Yes"
function echo_pass {
  # echo first argument in green
  printf "\e[32m✔ ${1} Installed"
  # reset colours back to normal
  printf "\033[0m \n"
}

comprobate_gpl(){
    local return_=1
    which $1 >/dev/null 2>&1 || { local return_=0; }
    echo "$return_"
}

yum=$(comprobate_gpl "yum")
apt=$(comprobate_gpl "apt")
gestor=""
if [ $apt -eq "1" ]; then
    sudo apt update
    gestor="apt"
  elif [ $yum -eq "1" ]; then
    sudo yum update
    gestor="yum"
fi

check_tool_and_install(){
    if type "$1" &>/dev/null; then
        echo_pass $1
    else
        echo_fail $1
        if [  $apt -eq "1" ]; then
            sudo apt install $1 -y
          elif [  $yum -eq "1" ]; then
            sudo yum install $1 -y
        fi
    fi
}

install_requirements(){
    echo "Install Requirements"
    for tool in ${tools_requirements[*]}
    do
        check_tool_and_install $tool
    done
}

echo -e "\n\n\n ${RED}${BOLD}Agregar IP al archivo /etc/hosts${NONE}"
sleep 3
hostS="${i}   ${arg}"
echo "Password of user root:"
sleep 1
su -c "echo -e ${hostS} >> /etc/hosts"
cat /etc/hosts

echo -e "\n\n\n ${RED}${BOLD}Instalar requerimientos para PYTHON${NONE}"
sleep 3
install_requirements
sudo $gestor install python3-pip
python3 -m pip install --user virtualenv

echo -e "\n\n\n ${RED}${BOLD}Creando entorno virtual de PYTHON${NONE}"
sleep 3
mkdir $envPath $daskPath
cd $envPath
python3 -m virtualenv daskEnv -p python3
source $envPath/daskEnv/bin/activate
cd $daskPath

echo -e "\n\n\n ${RED}${BOLD}Instalar requirements del entorno virtual${NONE}"
sleep 3
pip install -r ${url_requirements}

echo -e "\n\n\n"
echo -e "${RED}${BOLD}Run worker:${NONE} \t\n 1) ${GREEN}${BOLD}cd ${daskPath} ${NONE} \t\n 2) ${GREEN}${BOLD}source ${envPath}/daskEnv/bin/activate  ${NONE} \t\n 3) ${GREEN}${BOLD}dask-worker ${arg}:9796 ${NONE}"

#delete script
rm ~/add-worker.sh
