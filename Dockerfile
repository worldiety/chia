# ================================
# Build image
# ================================
FROM swift:5.1-bionic as builder
LABEL maintainer="julian.kahnert@worldiety.de"

WORKDIR /build-folder
RUN mkdir /bins

# Install chia
COPY . .
RUN swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/chia /bins

# Install Swift Dependencies
## SwiftLint
RUN git clone --recurse-submodules https://github.com/realm/SwiftLint SwiftLint && \
    cd SwiftLint && \
    swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/swiftlint /bins


# ================================
# Run image
# ================================
FROM swift:5.1-bionic-slim
LABEL maintainer="julian.kahnert@worldiety.de"

WORKDIR /project
VOLUME /project

COPY --from=builder /bins /usr/bin/

# Install Linux Dependencies


RUN rm -rf /build-folder && rm -rf /var/lib/apt/lists/*

CMD chia
