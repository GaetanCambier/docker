#!/bin/bash
set -e

BIND_DATA_DIR=${DATA_DIR}/bind

create_bind_data_dir() {
  mkdir -m 0775 -p ${BIND_DATA_DIR}

  # populate default bind configuration if it does not exist
  if [ ! -d ${BIND_DATA_DIR}/etc ]; then
    mv /etc/bind ${BIND_DATA_DIR}/etc
  fi
  rm -rf /etc/bind
  ln -sf ${BIND_DATA_DIR}/etc /etc/bind

  if [ ! -d ${BIND_DATA_DIR}/lib ]; then
    mkdir -m 0775 -p ${BIND_DATA_DIR}/lib
  fi
  rm -rf /var/lib/bind
  ln -sf ${BIND_DATA_DIR}/lib /var/lib/bind

  if [ ! -d ${BIND_DATA_DIR}/log ]; then
    mkdir -m 0775 -p ${BIND_DATA_DIR}/log
  fi
  rm -rf /var/log
  ln -sf ${BIND_DATA_DIR}/log /var/log

  chmod -R 0775 ${BIND_DATA_DIR}
  chown -R root:${BIND_USER} ${BIND_DATA_DIR}
}

create_pid_dir() {
  mkdir -m 0775 -p /var/run/named
  chown -R root:${BIND_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -m 0775 -p /var/cache/bind
  chown -R root:${BIND_USER} /var/cache/bind
}

create_pid_dir
create_bind_data_dir
create_bind_cache_dir

# allow arguments to be passed to named
if [[ ${1:0:1} == "-" ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == "named" || ${1} == $(which named) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch named
if [[ -z ${1} ]]; then
  echo "Starting named..."
  exec $(which named) -u ${BIND_USER} -f ${EXTRA_ARGS}
else
  exec "$@"
fi

