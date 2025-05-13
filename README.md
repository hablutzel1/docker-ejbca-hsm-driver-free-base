# EJBCA HSM Driver Base

An alternative base image for creating custom HSM drivers for EJBCA.

This is a free alternative to `registry.primekey.com/primekey/hsm-driver-base` (see around https://github.com/Keyfactor/keyfactorcommunity/blob/main/hsm-integration/hsm-driver-softhsm/Containerfile).

## Overview

This image serves as a foundation for building HSM drivers compatible with EJBCA. It's designed to work with the default EJBCA images (e.g. keyfactor/ejbca-ce) which loads `/opt/*/environment-hsm` files during startup.

## Usage

1. Create a child image that inherits from this base
2. Add your HSM-specific configurations and dependencies

### Caveats

Do not `COPY` from the child `Dockerfile` directly to `/opt/caml-crush-client`. Instead use an `environment-hsm` to copy the files to the mounted volume.

## Custom EJBCA Image

Refer to the `custom-ejbca-ce-sample/` directory for an example of how to customize the base EJBCA image to include `libtirpc`, which is required by the Caml Crush client.
