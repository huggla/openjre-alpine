FROM alpine:3.7

# Image-specific BEV_NAME variable.
# ---------------------------------------------------------------------
ENV BEV_NAME="openjre"
# ---------------------------------------------------------------------

ENV BIN_DIR="/usr/local/bin" \
    SUDOERS_DIR="/etc/sudoers.d" \
    CONFIG_DIR="/etc/$BEV_NAME" \
    LANG="en_US.UTF-8"
ENV BUILDTIME_ENVIRONMENT="$BIN_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"

# Image-specific buildtime environment variables.
# ---------------------------------------------------------------------
ENV OPENJDK_DIR="/usr/lib/jvm/java-1.8-openjdk" \
    JAVA_VERSION="8u151" \
    JAVA_ALPINE_VERSION="8.151.12-r0"
ENV JAVA_HOME="$OPENJDK_DIR/jre"
# ---------------------------------------------------------------------

COPY ./bin ${BIN_DIR}

# Image-specific COPY commands.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
    
RUN env | grep "^BEV_" > "$BUILDTIME_ENVIRONMENT" \
 && addgroup -S sudoer \
 && adduser -D -S -H -s /bin/false -u 100 -G sudoer sudoer \
 && (getent group $BEV_NAME || addgroup -S $BEV_NAME) \
 && (getent passwd $BEV_NAME || adduser -D -S -H -s /bin/false -u 101 -G $BEV_NAME $BEV_NAME) \
 && touch "$RUNTIME_ENVIRONMENT" \
 && apk add --no-cache sudo \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$BIN_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "REV_*"' > "$SUDOERS_DIR/docker2" \
 && echo "sudoer ALL=(root) NOPASSWD: $BIN_DIR/start" >> "$SUDOERS_DIR/docker2"

# Image-specific RUN commands.
# ---------------------------------------------------------------------
RUN apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" \
 && ln "$OPENJDK_DIR/jre/bin/"* "$BIN_DIR/" \
 && rm -rf "$OPENJDK_DIR/bin" "$OPENJDK_DIR/lib"
# ---------------------------------------------------------------------
    
RUN chmod go= /bin /sbin /usr/bin /usr/sbin \
 && chown root:$BEV_NAME "$BIN_DIR/"* \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && chown root:sudoer "$BIN_DIR/sudo" "$BUILDTIME_ENVIRONMENT" "$RUNTIME_ENVIRONMENT" \
 && chown root:root "$BIN_DIR/start"* \
 && chmod u+s "$BIN_DIR/sudo" \
 && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
 && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" "$SUDOERS_DIR/docker"*
 
USER sudoer

# Image-specific runtime environment variables.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------

CMD ["sudo","start"]
