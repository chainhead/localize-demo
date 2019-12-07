#! /bin/bash
#
# Original version - https://github.com/alex-leonhardt/k8s-mutate-webhook/blob/master/ssl/ssl.sh
#
set -o errexit

CONF_DIR=../conf
CERTS_DIR=../certs
YAML_DIR=../k8s
APP="${1:-mutate}"
NAMESPACE="${2:-default}"
CSR_NAME="${APP}.${NAMESPACE}.csr"

[ -d ${CERTS_DIR} ] || mkdir ${CERTS_DIR}

echo "Creating key pair - ${APP}.${NAMESPACE}.key and ${APP}.${NAMESPACE}.pem"
openssl req -nodes -x509 -newkey rsa:2048 -subj "/CN=${CSR_NAME}" -keyout ${CERTS_DIR}/${APP}.${NAMESPACE}.key -out ${CERTS_DIR}/${APP}.${NAMESPACE}.pem -days 365 -config ${CONF_DIR}/csr.conf

echo "Creating CSR - ${CSR_NAME}"
sed -i '' "s/app/${APP}/g" ${CONF_DIR}/csr.conf
sed -i '' "s/namespace/${NAMESPACE}/g" ${CONF_DIR}/csr.conf
openssl req -new -key ${CERTS_DIR}/${APP}.${NAMESPACE}.key -subj "/CN=${CSR_NAME}" -out ${CERTS_DIR}/${CSR_NAME} -config ${CONF_DIR}/csr.conf
exit 8
echo "Checking for CSR object - ${CSR_NAME}"
if [ `oc get csr ${CSR_NAME} --as system:admin -n ${NAMESPACE} 2>/dev/null` ]; then
  echo "CSR ${CSR_NAME} found. Deleting it."
  oc delete csr ${CSR_NAME} --as system:admin -n ${NAMESPACE} || exit 8
else
  echo "CSR ${CSR_NAME} not found."
fi
	
echo "Creating CSR object - ${CSR_NAME}"
sed "s/CSR_NAME/${CSR_NAME}/g" ${YAML_DIR}/csr-template.yaml > ${YAML_DIR}/csr.yaml
export ${CSR_BASE64_STRING}=`cat ${CERTS_DIR}/${CSR_NAME} | base64 | tr -d '\n'`
sed -i '' "s/CSR_BASE64/${CSR_BASE64_STRING}/g" ${YAML_DIR}/csr.yaml
oc create -f ${YAML_DIR}/csr.yaml --as system:admin -n ${NAMESPACE} && oc adm certificate approve ${CSR_NAME} --as system:admin -n ${NAMESPACE}

echo "Creating secret for webhook server"
oc create secret webhook-tls-secret --cert=${CERTS_DIR}/${APP}.${NAMESPACE}.pem --key=${CERTS_DIR}/${APP}.${NAMESPACE}.key -n ${NAMESPACE}
