FROM swift:5.1-bionic
LABEL maintainer="julian.kahnert@worldiety.de"

WORKDIR /build-folder

# Install chia
###############################################################################

COPY . .
RUN swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/chia /usr/bin


# Install Dependencies
###############################################################################

# SwiftLint
RUN git clone --recurse-submodules https://github.com/realm/SwiftLint SwiftLint && cd SwiftLint && \
    swift build --configuration release && \
    mv `swift build --configuration release --show-bin-path`/swiftlint /usr/bin


###############################################################################

RUN rm -rf /build-folder

WORKDIR /project
VOLUME /project

CMD chia
