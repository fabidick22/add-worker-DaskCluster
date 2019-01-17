#!/usr/bin/env bash

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
tools_requirements=(git python3 make wget curl)
url_requirements="https://raw.githubusercontent.com/fabidick22/add-worker-DaskCluster/master/requirements.txt"
daskPath=~/daskCluster
envPath=~/virtualEnv


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

#echo "ip scheduler = ${i}"
#echo "arg = ${arg}"
hostS="\n${i}\t${arg}"
echo "Password of user root:"
sleep 2
su -c "echo -e ${hostS} >> /etc/hosts"

echo "Instalar requerimientos"
install_requirements
sudo $gestor install python3-pip
python3 -m pip install --user virtualenv

#install Dask
mkdir envPath daskPath
cd envPath
python3 -m virtualenv daskEnv -p python3
source envPath/daskEnv/bin/activate
cd daskPath
pip install -r ${url_requirements}

echo $"\e[32;1m Run worker: dask-worker ${arg}:9796 \e[0m"
