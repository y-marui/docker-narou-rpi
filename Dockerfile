FROM ruby:2.7.0

LABEL maintainer "whiteleaf <2nd.leaf@gmail.com>"

ENV NAROU_VERSION 3.5.1
ENV AOZORAEPUB3_VERSION 1.1.0b55Q
ENV AOZORAEPUB3_FILE AozoraEpub3-${AOZORAEPUB3_VERSION}
ENV KINDLEGEN_FILE kindlegen_linux_2.6_i386_v2_9.tar.gz
ENV LANG C.UTF-8
ENV LANGUAGE en_US:
ENV LC_ALL C.UTF-8

WORKDIR /temp

RUN set -x \
     # install AozoraEpub3
     && wget https://github.com/kyukyunyorituryo/AozoraEpub3/releases/download/${AOZORAEPUB3_VERSION}/${AOZORAEPUB3_FILE}.zip \
     && unzip -q ${AOZORAEPUB3_FILE} \
     && mv ${AOZORAEPUB3_FILE} /aozoraepub3 \
     # install openjdk8 instead of openjdk11
     && apt-get update \
     && apt-get install -y openjdk-11-jdk \
     calibre \
     epub-utils \
     libebook-tools-perl \
     libepub-dev \
     libepub0 \
     calibre \
     poppler-data \
     fonts-takao-gothic \
     fonts-takao-mincho \
     make \
     gcc \
     cron \
     # install Narou.rb
     && gem install narou -v ${NAROU_VERSION} --no-document

WORKDIR /novel

COPY init.sh /usr/local/bin
RUN chmod 777 /usr/local/bin/init.sh

# install kindlegen alternative
COPY kindlegen /aozoraepub3
RUN chmod 777 /aozoraepub3/kindlegen \
     # setting AozoraEpub3
     && mkdir .narousetting \
     && narou init -p /aozoraepub3 -l 1.8 \
     && rm -rf /temp

EXPOSE 33000-33001

RUN echo "0 1 * * * cd /novel; narou u" >> /var/spool/cron/crontabs/root

ENTRYPOINT ["init.sh"]
CMD ["/etc/init.d/cron", "start", ";", "narou", "web", "-np", "33000"]
