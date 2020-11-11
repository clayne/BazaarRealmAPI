# -*- mode: dockerfile -*-

# You can override this `--build-arg BASE_IMAGE=...` to use different
# version of Rust or OpenSSL.
ARG BASE_IMAGE=ekidd/rust-musl-builder:nightly-2020-10-08

# Our first FROM statement declares the build environment.
FROM ${BASE_IMAGE} AS builder

# Add our source code.
ADD --chown=rust:rust . ./

ENV SQLX_OFFLINE true
# Build our application.
RUN cargo build --release

# Now, we need to build our _real_ Docker container, copying in `using-sqlx`.
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder \
    /home/rust/src/target/x86_64-unknown-linux-musl/release/bazaar_realm_api \
    /usr/local/bin/

CMD /usr/local/bin/bazaar_realm_api