# ================================
# Build image
# ================================
FROM swift:5.5-xenial as builder
LABEL maintainer="julian.kahnert@worldiety.de"

WORKDIR /build-folder
RUN mkdir /builder-bins
RUN mkdir /builder-libs

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && \
    apt-get install -y libsqlite3-dev

# Install chia
COPY . .
RUN swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/chia /builder-bins

# Install Swift Dependencies
## SwiftLint
RUN git clone https://github.com/realm/SwiftLint SwiftLint && \
    cd SwiftLint && \
    swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/swiftlint /builder-bins && \
    cp /usr/lib/libsourcekitdInProc.so /builder-libs && \
    cd /build-folder


# ================================
# Run image
# ================================
FROM swift:5.5-xenial-slim
LABEL maintainer="julian.kahnert@worldiety.de"

WORKDIR /project
VOLUME /project

COPY --from=builder /builder-bins /usr/bin/
COPY --from=builder /builder-libs /usr/lib/

# Install Linux Dependencies


RUN rm -rf /build-folder && rm -rf /var/lib/apt/lists/*

CMD chia
