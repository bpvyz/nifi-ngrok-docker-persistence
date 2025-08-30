FROM apache/nifi:1.28.1
ENV NIFI_HOME=/opt/nifi/nifi-current
ENV CERTS_DIR=${NIFI_HOME}/certs
ENV KEYSTORE_PASS=tinboy
ENV TRUSTSTORE_PASS=tinboy
ENV KEYSTORE_PATH=${CERTS_DIR}/keystore.jks
ENV TRUSTSTORE_PATH=${CERTS_DIR}/truststore.jks
ENV KEYSTORE_TYPE=JKS
ENV TRUSTSTORE_TYPE=JKS
ENV NIFI_WEB_HTTPS_PORT=8443
ENV NIFI_WEB_HTTPS_HOST=0.0.0.0
ENV NIFI_WEB_PROXY_HOST=localhost
# Create folder for certs
RUN mkdir -p ${CERTS_DIR}
# Generate keystore
RUN keytool -genkeypair -alias nifi-key \
    -keyalg RSA -keysize 2048 -validity 36500 \
    -keystore ${KEYSTORE_PATH} -storepass ${KEYSTORE_PASS} \
    -dname "CN=nifi.local, OU=OrgUnit, O=Org, L=City, ST=State, C=Country" \
    -ext SAN=dns:nifi.local,ip:127.0.0.1,ip:127.0.0.1
# Export certs
RUN keytool -export -alias nifi-key -file ${CERTS_DIR}/nifi-cert.cer -keystore ${KEYSTORE_PATH} -storepass ${KEYSTORE_PASS}
# Generate truststore and import certs
RUN keytool -import -trustcacerts -alias nifi-cert -file ${CERTS_DIR}/nifi-cert.cer -keystore ${TRUSTSTORE_PATH} -storepass ${TRUSTSTORE_PASS} -noprompt
WORKDIR ${NIFI_HOME}
# Modify nifi.properties
RUN sed -i \
    -e "s|^nifi.security.keystore=.|nifi.security.keystore=${KEYSTORE_PATH}|" \
    -e "s|^nifi.security.keystoreType=.|nifi.security.keystoreType=${KEYSTORE_TYPE}|" \
    -e "s|^nifi.security.keystorePasswd=.|nifi.security.keystorePasswd=${KEYSTORE_PASS}|" \
    -e "s|^nifi.security.truststore=.|nifi.security.truststore=${TRUSTSTORE_PATH}|" \
    -e "s|^nifi.security.truststoreType=.|nifi.security.truststoreType=${TRUSTSTORE_TYPE}|" \
    -e "s|^nifi.security.truststorePasswd=.|nifi.security.truststorePasswd=${TRUSTSTORE_PASS}|" \
    -e "s|^nifi.web.https.port=.|nifi.web.https.port=${NIFI_WEB_HTTPS_PORT}|" \
    -e "s|^nifi.web.https.host=.|nifi.web.https.host=${NIFI_WEB_HTTPS_HOST}|" \
    -e "s|^nifi.web.proxy.host=.*|nifi.web.proxy.host=${NIFI_WEB_PROXY_HOST}|" \
    conf/nifi.properties