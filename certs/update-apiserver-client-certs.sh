#! /bin/bash
OLDPATH=`pwd`
ROOT=`cd $(dirname $0); pwd`
cd ${ROOT}
function finish {
    cd ${OLDPATH} 
}
trap finish EXIT
OUTPUT=${ROOT}/output

mkdir -p ${OUTPUT}

# apiserver 
# apiserver client cert/key
bin/cfssl gencert -ca=root/ca.pem -ca-key=root/ca-key.pem \
    -config=config/config-profiles.json \
    -profile=client config/config-apiserver-client.json | \
    bin/cfssljson -bare ${OUTPUT}/apiserver-client
chmod 0644 ${OUTPUT}/*

type openssl >/dev/null 2>&1 && {
    cat ${OUTPUT}/apiserver-client.pem | openssl x509 -noout -text
}

echo; echo; echo
echo "--------------------------------------------------------------------------------------"
echo "|                                                                                    |"
echo "|    you need to reinit-kubeconfig manually(execute ./reinit-kubeconfig.sh)          |"
echo "|                                                                                    |"
echo "--------------------------------------------------------------------------------------"
echo; echo; echo
