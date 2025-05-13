FROM keyfactor/ejbca-ce:9.1.1

USER 0

# TODO try to make the Caml Crush client not depend on libtirpc as it isn't installed in recent versions of keyfactor/ejbca-ce like 9.1.1 (while it was in older ones, e.g. 7.11.0). From https://github.com/caml-pkcs11/caml-crush/blob/a1e438ee8bee9d5876fd1d0ccff9443e0e7dca1d/configure.ac#L391, apparently there are other options.
RUN microdnf install -y libtirpc

USER 10001
