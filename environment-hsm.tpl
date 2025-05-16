export PKCS11PROXY_SOCKET_PATH=${P11SERVER:-localhost}:4444

# TODO instead of directly using ID 200, first check if that ID is not used by a different library and keep incrementing until finding a free ID.
caml_crush_conf_id=200

add_to_ejbca_web_properties() {
    key=$1
    value=$2
    sed -i "/${key}/d" /opt/keyfactor/ejbca/conf/web.properties
    echo "${key}=${value}" >> /opt/keyfactor/ejbca/conf/web.properties
}

add_to_ejbca_web_properties "cryptotoken.p11.lib.${caml_crush_conf_id}.name" "<HSM_PKCS11_LIBRARY_NAME>"
add_to_ejbca_web_properties "cryptotoken.p11.lib.${caml_crush_conf_id}.file" "/opt/caml-crush-client/libp11client.so"
