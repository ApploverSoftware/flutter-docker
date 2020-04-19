FROM phusion/baseimage:0.11
LABEL maintainer="Applover Software House <docker-hub@applover.pl>"

CMD ["/sbin/my_init"]

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "4333796"
ENV VERSION_BUILD_TOOLS "29.0.2"
ENV VERSION_TARGET_SDK "29"

ENV ANDROID_HOME "/sdk"
ENV FLUTTER_HOME "/flutter"

ENV PATH "$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$FLUTTER_HOME/tools/bin"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update --fix-missing
RUN apt-get -y install --no-install-recommends \
    curl \
    openjdk-8-jdk \
    unzip \
    zip \
    git \
    ruby2.6 \
    ruby2.6-dev \
    file \
    lcov \
    zlib1g-dev \
    patch \
    libxml2-dev \
    build-essential \
    liblzma-dev \
    libxslt1-dev \
    ssh

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d /sdk && rm -rf /tools.zip

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-$VERSION_TARGET_SDK"
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;$VERSION_BUILD_TOOLS"
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "platform-tools"

RUN mkdir -p $HOME/.android && touch $HOME/.android/repositories.cfg
RUN $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN git clone https://github.com/flutter/flutter.git -b stable
RUN $FLUTTER_HOME/bin/flutter config  --no-analytics &&  $FLUTTER_HOME/bin/flutter precache
RUN $FLUTTER_HOME/bin/flutter doctor -v

ADD Gemfile Gemfile

RUN gem install bundler && gem install pkg-config
RUN gem install nokogiri -- --use-system-libraries && bundle install

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*