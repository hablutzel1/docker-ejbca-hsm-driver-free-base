#!/bin/sh
set -e

rm -rf /opt/caml-crush-client/*
cp /tmp/base/libp11client.so /opt/caml-crush-client/libp11client.so
sed "s/<HSM_PKCS11_LIBRARY_NAME>/${HSM_PKCS11_LIBRARY_NAME}/g" /tmp/base/environment-hsm.tpl > /opt/caml-crush-client/environment-hsm

for subDirectory in /opt/* ; do
    if [ -d "$subDirectory" ] && [ "$subDirectory" != "/opt/caml-crush-client" ]; then
        if [ -f "$subDirectory/environment-hsm" ] ;
        then
            echo "Sourcing $subDirectory/environment-hsm..."
            . "$subDirectory/environment-hsm"
            break
        fi
    fi
done

if [ -z "${HSM_PKCS11_LIBRARY}" ]; then
    echo "ERROR: HSM_PKCS11_LIBRARY environment variable is not set. This container must be extended to add your HSM PKCS#11 driver."
    exit 1
fi

sed -i 's/127.0.0.1:4444/0.0.0.0:4444/g' /opt/caml-crush-server/pkcs11proxyd.conf
sed -i "64i\libnames=\":${HSM_PKCS11_LIBRARY};\";" /opt/caml-crush-server/pkcs11proxyd.conf

# The following combination of trap and wait allows to handle CTRL + C to stop the container after a foreground `docker run`.
# TODO determine why pkcs11proxyd doesn't handle SIGINT by default (is that standard behavior for programs?). See https://blobfishpe.atlassian.net/wiki/spaces/CFTECH/pages/597786642/OCaml+-+Sys#Handle-signals
# TODO determine why CTRL + C works to stop pkcs11proxyd when it is directly run from a terminal!
trap "echo Received SIGINT or SIGTERM. Stopping pkcs11proxyd..." INT TERM
/opt/caml-crush-server/pkcs11proxyd -conf /opt/caml-crush-server/pkcs11proxyd.conf -fg &
wait
