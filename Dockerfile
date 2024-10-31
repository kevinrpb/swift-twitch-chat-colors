# ================================
# Build image
# ================================
FROM swift:6.0-noble AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get -q update \
	&& apt-get -q dist-upgrade -y \
	&& apt-get install -y \
		libjemalloc-dev \
	&& rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve \
	$([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .

# Build everything, with optimizations, with static linking, and using jemalloc
RUN swift build -c release \
	--static-swift-stdlib \
	-Xlinker -ljemalloc

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/twitch-chat-colors" ./

# Copy static swift backtracer binary to staging area
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resouces from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/public ] && { mv /build/public ./public && chmod -R a-w ./public; } || true
# RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:noble

# Add sources needed for `apt-get build-dep`
# This is only needed when building libcurl from source (read below)
# RUN true \
# 	&& echo "deb-src http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse" >> /etc/apt/sources.list \
# 	&& echo "deb-src http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list \
# 	&& echo "deb-src http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list \
# 	&& echo "deb-src http://archive.ubuntu.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get -q update \
	&& apt-get -q dist-upgrade -y \
	&& apt-get -q install -y \
		libjemalloc2 \
		ca-certificates \
		tzdata \
# ! libcurl4 doesn't currently include the experimental websockets impl that we need,
# ! but we are using websocket-kit instead. We do need libcurl to use URLSession.
# ! If FoundationNetworking ever solves https://github.com/swiftlang/swift-corelibs-foundation/issues/4730
# ! we can go back to compiling libcurl (see below) with WS support and use URLSession.
		libcurl4 \
# If your app or its dependencies import FoundationXML, also install `libxml2`.
		# libxml2 \
# Add these if you're building libcurl from source
		# git \
		# autoconf \
# Run this if you're building libcurl from source
	# && apt-get build-dep -y curl \
	&& rm -r /var/lib/apt/lists/*

# Build libcurl4 with websocket support
# RUN true \
# 	&& git clone https://github.com/curl/curl.git \
# 	&& cd curl \
# 	&& autoreconf -fi \
# 	&& ./configure --with-openssl --enable-websockets \
# 	&& make \
# 	&& make install \
# 	&& ln -s /usr/local/lib/libcurl.so /usr/lib/libcurl.so \
# 	&& ln -s /usr/local/lib/libcurl.so.4 /usr/lib/libcurl.so.4

# Create a hummingbird user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app hummingbird

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=hummingbird:hummingbird /staging /app

# Provide configuration needed by the built-in crash reporter and some sensible default behaviors.
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Ensure all further commands run as the hummingbird user
USER hummingbird:hummingbird

# Let Docker bind to port 8080
EXPOSE 8080

# Start the Hummingbird service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./twitch-chat-colors"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]
