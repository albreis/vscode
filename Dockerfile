FROM lscr.io/linuxserver/code-server
SHELL ["/bin/bash", "-c"]
RUN apt update
RUN apt-get update && apt-get install gpg && echo -n 'deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main' > /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C
RUN apt-get install cron vim systemctl zip unzip -y
RUN apt-get install software-properties-common -y
RUN apt-get install -y apt-transport-https ca-certificates curl
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install php8.1 php8.1-zip php8.1-xml php8.1-mysql php8.1-cli -y
RUN systemctl enable cron
# COPY wp-cron /etc/cron.d/wp-cron
# RUN chmod 0644 /etc/cron.d/wp-cron
# RUN crontab /etc/cron.d/wp-cron
RUN touch /var/log/cron.log
RUN curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /tmp/wp-cli.phar
RUN mv /tmp/wp-cli.phar /usr/local/bin/wp
RUN curl -o /tmp/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/v2.6.0/utils/wp-completion.bash
RUN source /tmp/wp-completion.bash
RUN chmod 0777 -R /home
COPY 99-cron /etc/cont-init.d/99-cron
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer global require albreis/phptest
ENV PATH="/config/.config/composer/vendor/bin:${PATH}"
RUN apt-get update && apt-get install -y ruby ruby-dev ruby-bundler build-essential kubectl
RUN gem install shopify-cli
COPY doctl /usr/local/bin
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN kubectl version --client
RUN gem install opencode_theme -v 1.0.7

ARG JDK_VERSION=11
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends libncurses5:i386 libc6:i386 libstdc++6:i386 lib32gcc1 lib32ncurses6 lib32z1 zlib1g:i386 && \
    apt-get install -y --no-install-recommends openjdk-${JDK_VERSION}-jdk && \
    apt-get install -y --no-install-recommends git wget unzip && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qt5-default
ARG GRADLE_VERSION=7.1.1
ARG GRADLE_DIST=bin
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-${GRADLE_DIST}.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip
ARG KOTLIN_VERSION=1.5.21
RUN cd /opt && \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip && \
    unzip *kotlin*.zip && \
    rm *kotlin*.zip
ARG ANDROID_SDK_VERSION=7302050
ENV ANDROID_SDK_ROOT /opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools && \
    rm *tools*linux*.zip
ENV JAVA_HOME /usr/lib/jvm/java-${JDK_VERSION}-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV KOTLIN_HOME /opt/kotlinc
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator
ENV LD_LIBRARY_PATH ${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib
ENV QTWEBENGINE_DISABLE_SANDBOX 1
ADD license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_SDK_ROOT