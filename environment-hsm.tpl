export PKCS11PROXY_SOCKET_PATH=${P11SERVER}:4444

# TODO instead of relying on 200 being always free, look for an available ID.
caml_crush_conf_id=200
echo "cryptotoken.p11.lib.${caml_crush_conf_id}.name=<HSM_PKCS11_LIBRARY_NAME>" >> /opt/keyfactor/ejbca/conf/web.properties
echo "cryptotoken.p11.lib.${caml_crush_conf_id}.file=/opt/caml-crush-client/libp11client.so" >> /opt/keyfactor/ejbca/conf/web.properties
