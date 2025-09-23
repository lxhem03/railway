# Base Image
FROM fedora:37

# Setup home directory, non-interactive shell, and timezone
RUN mkdir -p /bot /tgenc && chmod 777 /bot
WORKDIR /bot
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Lagos
ENV TERM=xterm

# Install Dependencies
RUN dnf -qq -y update && \
    dnf -qq -y install git bash xz wget curl pv jq python3-pip mediainfo psmisc procps-ng && \
    python3 -m pip install --upgrade pip setuptools && \
    dnf clean all

# Install FFmpeg with VP9 and AV1 support
RUN wget https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2023-12-18-12-47/ffmpeg-n6.1-20231218-linux64-gpl-6.1.tar.xz && \
    tar -xJf ffmpeg-n6.1-20231218-linux64-gpl-6.1.tar.xz && \
    cp ffmpeg-n6.1-20231218-linux64-gpl-6.1/bin/* /usr/bin/ && \
    rm -rf ffmpeg-n6.1-20231218-linux64-gpl-6.1.tar.xz ffmpeg-n6.1-20231218-linux64-gpl-6.1

# Verify FFmpeg codecs
RUN ffmpeg -codecs | grep -E 'vp9|av1' || { echo "FFmpeg does not support VP9 or AV1"; exit 1; }

# Copy files from repo to home directory
COPY . .

# Install Python requirements
RUN pip3 install --no-cache-dir -r requirements.txt

# Start bot
CMD ["bash", "run.sh"]
