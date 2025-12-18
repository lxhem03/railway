 FROM fedora:40

RUN mkdir -p /bot /tgenc && chmod 777 /bot
WORKDIR /bot
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Lagos
ENV TERM=xterm

RUN dnf -qq -y update && dnf -qq -y install git aria2 bash xz wget curl pv jq python3-pip mediainfo gcc psmisc procps-ng qbittorrent-nox && if [[ $(arch) == 'aarch64' ]]; then   dnf -qq -y install gcc fontconfig python3-devel; fi && python3 -m pip install --upgrade pip setuptools

RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/64/) && \
    wget -q https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux${arch}-gpl-7.1.tar.xz && tar -xvf *xz && cp *7.1/bin/* /usr/bin && rm -rf *xz && rm -rf *7.1

COPY . .

RUN pip3 install -r requirements.txt

RUN if [[ $(arch) == 'aarch64' ]]; then   dnf -qq -y history undo last; fi && dnf clean all

CMD ["bash","run.sh"]
