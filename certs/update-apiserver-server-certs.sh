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
# apiserver server cert/key
bin/hosts config/config-apiserver-server.json config/hosts-apiserver | \
bin/cfssl gencert -ca=root/ca.pem -ca-key=root/ca-key.pem              \
    -config=config/config-profiles.json                                \
    -profile=server - |                                                \
    bin/cfssljson -bare ${OUTPUT}/apiserver-server
chmod 0644 ${OUTPUT}/*

type openssl >/dev/null 2>&1 && {
    cat ${OUTPUT}/apiserver-server.pem | openssl x509 -noout -text
    echo "check hosts"
    cat ${OUTPUT}/apiserver-server.pem | openssl x509 -noout -text |\
        grep 'X509v3 Subject Alternative Name' -A 1 | \
        tail -n 1 | \
        sed 's/[,]/\n/g' | \
        tr -d ' ' | \
        awk -F':' '{print $2}' | \
        diff -ruN config/hosts-apiserver -
}
