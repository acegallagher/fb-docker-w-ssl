#!/usr/bin/env bash

# "/fb/letsencrypt/letsencrypt-gallagher.fun.cfg"
source $1 

LOG_FILE=${LOG_DIR}/letsencrypt_$(date +%F).log
mkdir -p $LOG_DIR

function log_msg {
    TIMESTAMP=$(date +"%F %T")
    echo "["$TIMESTAMP"] $1" | tee $LOG_FILE
}

pacman -Qs certbot &> /dev/null \
       || `log_msg "Install certbot *beeop* please" & exit` \
       && log_msg "Certbot will update certs for ${DOMAIN_NAME}"

UPDATED=0  # UTIL FUNCTION TO LOG ACTIVITY


log_msg "---------------------------------------------------"
log_msg $(env)
log_msg "Renewing SSL Certificates with Let's Encrypt CA";

cd $LETS_ENCRYPT_HOME;

# Renew certificate
certbot certonly \
   --standalone \
   --logs-dir ${LOG_DIR} \
   --config-dir ${LETS_ENCRYPT_HOME}/conf/ \
   --work-dir ${LETS_ENCRYPT_HOME}/work/ \
   --force-interactive \
   --renew-by-default \
   --agree-tos \
   -d "$DOMAIN_NAME,www.$DOMAIN_NAME" | tee $LOG_FILE

# Log and restart web server
if [ $? -ne 0 ]; then
        log_msg "Cert for "$DOMAIN_NAME" could NOT be renewed!"
else
        log_msg "Cert for "$DOMAIN_NAME" renewed!"
        UPDATED=1
fi 

# cert has been updated, restart the web server docker...
if [ $UPDATED -ne 0 ]; then
   log_msg "One or more certs has been updated. Restarting web server...."
   #service nginx reload
else
    log_msg "No cert updates."
fi
log_msg "All finished!!"exit 0
