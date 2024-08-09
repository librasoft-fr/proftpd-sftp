#!/bin/sh
set -e
DAEMON=proftpd
CONFPATH=/etc/proftpd/sftp

stop() {
	echo "Received INT or TERM. Shutting down $DAEMON"

	# Get PID
	pid=$(cat /tmp/${DAEMON}.pid)
	# Set TERM
	kill "${pid}"
}

# Trap signals (without SIG prefix)
trap 'signal_handler INT' INT
trap 'signal_handler TERM' TERM

if [ -n "$SFTP_TZ" ]; then
	cp -av /usr/share/zoneinfo/${SFTP_TZ} /etc/localtime
	echo ${SFTP_TZ} > /etc/timezone
fi

[ ! -e ${CONFPATH} ] && mkdir -p ${CONFPATH}
cd ${CONFPATH}
owner=$(ls -lnd ${CONFPATH} | tail -1 | awk -F' ' -v'OFS=:' '{print $3,$4}')
[ ! -e authorized_keys ] && mkdir authorized_keys && chown ${owner} authorized_keys
[ ! -e ftppasswd ] && touch ftppasswd && chown ${owner} ftppasswd && chmod 600 ftppasswd
[ ! -e ftpgroup ] && touch ftpgroup && chown ${owner} ftpgroup && chmod 600 ftpgroup
[ ! -e keys ] && mkdir keys && chown ${owner} keys
cd /

# Generating SSH host keys with PEM format to avoid error while starting that:
#   Wrong passphrase for this key.  Please try again.
#   2019-09-17 18:45:09,677 e6bd23049edb proftpd[7] e6bd23049edb: mod_sftp/1.0.0: error reading passphrase for SFTPHostKey '/etc/ssh/ssh_host_rsa_key': (unknown)
#   2019-09-17 18:45:09,677 e6bd23049edb proftpd[7] e6bd23049edb: mod_sftp/1.0.0: unable to use key in SFTPHostKey '/etc/ssh/ssh_host_rsa_key', exiting
#
#

if [ ! -e ${CONFPATH}/keys/ssh_host_rsa_key ]; then
  rm -rf /etc/ssh
  ln -s ${CONFPATH}/keys /etc/ssh
  ssh-keygen -A -m PEM
  find /etc/proftpd/sftp
  find /etc/ssh
  chown -R ${owner} ${CONFPATH}/keys/*
  rm /etc/ssh
fi

proftpd -n &

pid="$!"
echo "${pid}" > /tmp/${DAEMON}.pid
wait "${pid}" && exit $?

