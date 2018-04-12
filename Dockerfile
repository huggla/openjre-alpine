FROM huggla/alpine

ENV OPENJDK_DIR="/usr/lib/jvm/java-1.8-openjdk" \
    JAVA_VERSION="8u151" \
    JAVA_ALPINE_VERSION="8.151.12-r0"
ENV JAVA_HOME="$OPENJDK_DIR/jre"

COPY ./bin ${BIN_DIR}

RUN apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" \
 && ln "$OPENJDK_DIR/jre/bin/"* "$BIN_DIR/" 
# \ && rm -rf "$OPENJDK_DIR/bin" "$OPENJDK_DIR/lib"
 
