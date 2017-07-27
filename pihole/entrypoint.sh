#!/bin/sh
set -e

PROGRAM_DATA_DIR=${DATA_DIR}/bind

create_program_data_dir() {
  mkdir -p ${PROGRAM_DATA_DIR}

  # populate default bind configuration if it does not exist
  if [ ! -d ${PROGRAM_DATA_DIR}/etc ]; then
    mv /etc/pihole ${PROGRAM_DATA_DIR}/etc
    
  fi
  rm -rf /etc/pihole
  ln -sf ${PROGRAM_DATA_DIR}/etc /etc/pihole

  if [ ! -d ${PROGRAM_DATA_DIR}/var ]; then
    mkdir -p ${PROGRAM_DATA_DIR}/var/log/nginx
    
  fi
  touch ${PROGRAM_DATA_DIR}/var/log/nginx/access.log ${PROGRAM_DATA_DIR}/var/log/nginx/error.log
  chown -R nginx:nginx ${PROGRAM_DATA_DIR}/var/log/nginx
  touch ${PROGRAM_DATA_DIR}/var/log/pihole.log
  chmod 644 ${PROGRAM_DATA_DIR}/var/log/pihole.log
  chown dnsmasq:root ${PROGRAM_DATA_DIR}/var/log/pihole.log
  rm -rf /var/log/nginx
  ln -sf ${PROGRAM_DATA_DIR}/var /var/log
}

create_pid_dir() {
  mkdir -m 0775 -p /var/run/named
  chown root:${PROGRAM_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -m 0775 -p /var/cache/bind
  chown root:${PROGRAM_USER} /var/cache/bind
}

create_pid_dir
create_bind_data_dir
create_bind_cache_dir

# allow arguments to be passed to named
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == named || ${1} == $(which named) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch named
if [[ -z ${1} ]]; then
  echo "Starting pihole..."
  exec pihole-FTL no-deamon
  exec dnsmasq -7 /etc/dnsmasq.d --no-daemon
  exec php-fpm5 -d daemonize=no
  exec nginx -g "daemon off;"
else
  exec "$@"
fi

