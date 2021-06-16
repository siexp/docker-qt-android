# docker-qt-android
Docker image for CI\CD for qt based android applications

## How to configure image 
```
docker build --tag docker-qt-android --build-arg qt_packages="qtbase qttools qtdeclarative qtwebsockets qtandroidextras" .
```

## How to use in pipelines
### Bitbucket pipelines
```
image: siexp/docker-qt-android:ubuntu_21_04

pipelines:
  default:
    - step:
        name: Build and test
        script:
          # uncomment if you need submodules
          # - apt-get update && apt-get install git && git submodule update --recursive --init
          - mkdir build && cd build
          - cmake .. -GNinja -DCMAKE_FIND_ROOT_PATH=/opt/Qt/5.15.2/android/ -DCMAKE_PREFIX_PATH=/opt/Qt/5.15.2/android/ -DANDROID_TOOLCHAIN=clang -DCMAKE_BUILD_TYPE=Debug -DANDROID_NDK=/opt/android/sdk/ndk/21.4.7075529 -DCMAKE_TOOLCHAIN_FILE=/opt/android/sdk/ndk/21.4.7075529/build/cmake/android.toolchain.cmake -DANDROID_NATIVE_API_LEVEL=29 -DANDROID_ABI:STRING=arm64-v8a -DANDROID_BUILD_ABI_arm64-v8a:BOOL=ON -DANDROID_BUILD_ABI_armeabi-v7a:BOOL=ON -DANDROID_BUILD_ABI_x86_64:BOOL=ON
          - cmake --build . --target all --parallel $(nproc)
          # debug apk
          - /opt/Qt/5.15.2/android/bin/androiddeployqt --input android_deployment_settings.json --output android-build --android-platform android-29 --jdk "/usr/lib/jvm/java-8-openjdk-amd64/" --gradle
        artifacts:
          - build/android-build/build/outputs/apk/debug/android-build-debug.apk
```