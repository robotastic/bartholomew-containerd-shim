FROM --platform=${BUILDPLATFORM} scratch
COPY content /content
COPY templates /templates
COPY scripts /scripts
COPY config /config
COPY static /static
COPY modules /modules
COPY spin.toml .

