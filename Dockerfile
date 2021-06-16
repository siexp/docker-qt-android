FROM ubuntu:21.04

LABEL org.opencontainers.image.authors="elioni17@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/siexp/docker-qt-android"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/siexp/docker-qt-android"


RUN apt-get update --quiet && \
    apt-get install --quiet --yes --no-install-recommends openjdk-8-jdk unzip wget curl p7zip-full

# install android sdk
ARG sdk_version=commandlinetools-linux-6200805_latest.zip
ARG android_home=/opt/android/sdk
RUN mkdir -p ${android_home} && \
    wget --quiet --output-document=/tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# set environmental variables
ENV ANDROID_HOME=${android_home}
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

# install ndk and build tools
ARG android_api=android-29
ARG android_build_tools=30.0.2
ARG ndk_version=21.4.7075529
RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN sdkmanager --sdk_root=$ANDROID_HOME --install \
    "platform-tools" \
    "build-tools;${android_build_tools}" \
    "platforms;${android_api}" \
    "ndk;${ndk_version}"
# create symbolic link for licenses so qt can install required modules
RUN ln -s /opt/android/sdk/licenses /opt/android/sdk/ndk/licenses

# install qt
ARG qt_version=5.15.2
ENV QT_VERSION=${qt_version}
ARG qt_install_dir=/opt/Qt
ARG qt_packages=qtbase
RUN cd /tmp && \
    wget --quiet --output-document=install-qt.sh https://code.qt.io/cgit/qbs/qbs.git/plain/scripts/install-qt.sh && \
    chmod +x ./install-qt.sh && \
    ./install-qt.sh --directory ${qt_install_dir} --version ${qt_version} --target android --toolchain android ${qt_packages}

# packages required for building application
RUN apt-get install --quiet --yes --no-install-recommends cmake ninja-build

# clear cache
RUN rm -rf /tmp/* && rm -rf /var/lib/apt/lists/*