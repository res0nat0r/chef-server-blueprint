#!/usr/bin/env bash
# Author: Arem Chekunov
# Author email: scorp.dev.null@gmail.com
# repo: https://github.com/sc0rp1us/cehf-useful-scripts
# env and func's
set -x

_BACKUP_NAME="chef-backup_$(date +%Y-%m-%d)"
_BACKUP_USER="root"
_BACKUP_DIR="/var/backups"
_SYS_TMP="/tmp"
_TMP="${_SYS_TMP}/chef-backup/${_BACKUP_NAME}"

_pg_dump(){
su - opscode-pgsql -c "/opt/opscode/embedded/bin/pg_dumpall -c"
}

pg_running(){
  while [ `chef-server-ctl status postgresql | cut -d ':' -f 1` == 'down' ]; do
    echo "pg is down, sleeping 1"
    sleep 1
  done
}

syntax(){
        echo ""
        echo -e "\t$0 --backup                  # for backup"
        echo -e "\t$0 --restore </from>.tar.bz2 # for restore"
        echo ""
}

_chefBackup(){

echo "Backup function"

id ${_BACKUP_USER} &> /dev/null
    _BACKUP_USER_EXIST=$?
    if [[ ${_BACKUP_USER_EXIST} -ne 0 ]]; then
        echo "You should have a backup user"
    fi


set -e
set -x
rm -rf /var/opt/chef-backup
chef-server-ctl reconfigure
sleep 60 #wait for reconfigure
chef-server-ctl backup --yes
mv /var/opt/chef-backup/chef-backup-* /var/opt/chef-backup/chef-backup.tgz
}


_chefRestore(){
echo "Restore function"
    if [[ ! -f ${source} ]]; then
        echo "ERROR: file ${source} do not exist"
        exit 1
    fi

    set -e
    set -x
    chef-server-ctl reconfigure
    sleep 60 #wait for reconfigure
    chef-server-ctl restore ${source} -c
    sleep 30
    #chef-server-ctl reconfigure
    #sleep 30
    chef-manage-ctl reconfigure
    cd ~
    rm -Rf ${_TMP_RESTORE}
}

# tests
if [[ ! -x /opt/opscode/embedded/bin/pg_dump ]];then
    echo "Use it script only on chef-server V11"
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    echo "You should to be root"
    exit 1
fi

# body
while [ "$#" -gt 0 ] ; do
    case "$1" in
        -h|--help)
            syntax
            exit 0
            ;;
        --backup)
            action="backup"
            shift 1
            ;;
        --restore)
            action="restore"
            source="${2}"
            break
            ;;
        *)
            syntax
            exit 1
            ;;

    esac
done


if [[ ${action} == "backup" ]];then
        _chefBackup
elif [[ ${action} == "restore" ]];then
        _chefRestore
else
        syntax
        exit 1
fi
