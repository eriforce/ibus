# Dockerfile for building IBus project
# Based on the CI workflow configuration

FROM ubuntu:jammy

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV UCD_DIR=/usr/share/unicode
ENV DISABLE_DAEMONIZE_IN_TESTS=1

# Update package manager and install git first
RUN apt-get update -qq -y && \
    apt-get install -q -y git

# Install build dependencies
# These packages are extracted from the CI workflow
RUN apt-get install -y \
    # For autogen.sh
    autopoint \
    strace \
    # For make (from https://packages.ubuntu.com/search?searchon=sourcenames&keywords=ibus)
    desktop-file-utils \
    dbus-x11 \
    gobject-introspection \
    gtk-doc-tools \
    iso-codes \
    libdconf-dev \
    libdbusmenu-gtk3-dev \
    libgirepository1.0-dev \
    libglib2.0-dev \
    libgtk-3-bin \
    libgtk-3-dev \
    libgtk-4-dev \
    libgtk2.0-dev \
    libnotify-dev \
    libtool \
    libwayland-dev \
    python-gi-dev \
    python3-all \
    systemd \
    unicode-cldr-core \
    unicode-data \
    valac \
    valac-0.56-vapi \
    wayland-protocols \
    wget \
    # Additional useful packages
    build-essential \
    autotools-dev \
    automake \
    gettext \
    intltool \
    pkg-config \
    dconf-cli

# Verify unicode-data installation
RUN dpkg -l | grep unicode-data

# Set working directory
WORKDIR /workspace

# Copy source code
COPY . .

# Download wayland-client.vapi if not available
RUN if ! ls /usr/share/vala-*/vapi/wayland-client.vapi; then \
    wget https://gitlab.gnome.org/GNOME/vala/-/raw/0.56/vapi/wayland-client.vapi && \
    mv wayland-client.vapi bindings/vala/.; \
    fi

# Configure git safe directory
RUN git config --global --add safe.directory /workspace

# Run autogen.sh with configure options
# Options are based on https://salsa.debian.org/debian/ibus/-/blob/master/debian/rules
RUN ./autogen.sh \
    --enable-gtk-doc \
    --with-python=/usr/bin/python3 \
    --with-ucd-dir=${UCD_DIR} \
    --enable-install-tests

# Build the project
RUN make -j$(nproc)

# Run distcheck (similar to CI but without some problematic tests)
RUN make -j$(nproc) distcheck \
    DISTCHECK_CONFIGURE_FLAGS=" \
    --enable-gtk-doc \
    --disable-schemas-install \
    --enable-memconf \
    --with-python=/usr/bin/python3 \
    --with-ucd-dir=${UCD_DIR} \
    --enable-install-tests \
    " \
    DISABLE_GUI_TESTS=" \
    ibus-compose ibus-keypress test-stress xkb-latin-layouts \
    " \
    VERBOSE=1 \
    DESTDIR="/tmp/ibus-install"

# Install to a specific directory
RUN make install DESTDIR="/tmp/ibus-install"

# Create a final stage with just the installed files
FROM ubuntu:jammy as runtime

# Install runtime dependencies
RUN apt-get update -qq -y && \
    apt-get install -y \
    libglib2.0-0 \
    libgtk-3-0 \
    libgtk-4-1 \
    libgtk2.0-0 \
    libdconf1 \
    libnotify4 \
    libwayland-client0 \
    python3 \
    python3-gi \
    dbus-x11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy installed files from build stage
COPY --from=0 /tmp/ibus-install /

# Set up environment
ENV PATH="/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

# Default command
CMD ["ibus-daemon", "--help"]
