# TODO try to use AlmaLinux for building.
FROM debian:11 AS builder

# TODO reduce to the minimum.
# Disable pipelining to prevent the errors mentioned in https://blobfishpe.atlassian.net/wiki/spaces/CFTECH/pages/704774149/apt-get+-+Networking#Disable-pipelining and observed during build operations in Rancher Desktop on macOS. Note that the cause for these errors wasn't identified.
RUN apt update && apt -o Acquire::http::Pipeline-Depth=0 install -y autoconf make gcc git ocaml-nox camlidl coccinelle libocamlnet-ocaml-dev libocamlnet-ocaml-bin libconfig-file-ocaml-dev camlp4

RUN git clone https://github.com/caml-pkcs11/caml-crush.git
WORKDIR /caml-crush
RUN git checkout v1.0.12

# To prevent the problem described in https://github.com/OpenSC/OpenSC/issues/2875#issuecomment-3330857445
RUN sed -i 's|-Wl,-soname,$(CUSTOM_SONAME)|-Wl,-soname,$(CUSTOM_SONAME),-Bsymbolic|g' src/client-lib/Makefile.in

RUN ./autogen.sh
RUN ./configure --with-idlgen --with-rpcgen --with-daemonize --without-filter --with-libnames=""
RUN make


FROM almalinux:9-minimal

RUN microdnf install -y procps

WORKDIR /opt

COPY --from=builder /caml-crush/src/pkcs11proxyd/pkcs11proxyd /opt/caml-crush-server/pkcs11proxyd
COPY --from=builder /caml-crush/src/pkcs11proxyd/pkcs11proxyd.conf /tmp/base/pkcs11proxyd.conf

COPY --from=builder /caml-crush/src/client-lib/libp11client.so /tmp/base/libp11client.so

COPY environment-hsm.tpl /tmp/base/environment-hsm.tpl

ENV HSM_PKCS11_LIBRARY_NAME="Caml Crush"

COPY start.sh /opt/bin/start.sh
RUN chmod +x /opt/bin/start.sh
ENTRYPOINT ["/opt/bin/start.sh"]

# Note the following health check doesn't apply to K8s (https://stackoverflow.com/a/41476481/320594).
# TODO It doesn't make sense to load EJBCA if the HSM is not ready!. Make this health check aware of the connectivity status to the HSM, e.g. with pkcs11-tool. An slot ID to be used to check connectivity could be required as an environment variable (e.g. HEALTHCHECK_SLOT_ID).
HEALTHCHECK --interval=1s CMD ps -e | grep pkcs11proxyd | grep -v grep
