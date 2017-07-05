set -e

function download() {
  if hash curl 2>/dev/null; then
    curl -s -L -o "$2" "$1"
  elif hash wget 2>/dev/null; then
    wget -O "$2" "$1"
  else
    echo >&2 "No supported download tool installed. Please get either wget or curl."
    exit
  fi
}

function installsdk() {
  PROXY_ARGS=""
  if [[ ! -z "$HTTPS_PROXY" ]]; then
    PROXY_HOST="$(echo $HTTPS_PROXY | cut -d : -f 1,1)"
    PROXY_PORT="$(echo $HTTPS_PROXY | cut -d : -f 2,2)"
    PROXY_ARGS="--proxy=http --proxy_host=$PROXY_HOST --proxy_port=$PROXY_PORT"
  fi

  echo y | "$ANDROID_HOME"/tools/bin/sdkmanager $PROXY_ARGS "$@"
}

function installAndroidSDK {
  if [[ ! -d "$HOME/android-sdk" ]]; then
    DL_CACHE_FILE="$HOME/dl_cache/tools.zip"
    mkdir -p "$(basename "$DL_CACHE_FILE")"
    download 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip' "$DL_CACHE_FILE"
    unzip -qod "$HOME/android-sdk" "$DL_CACHE_FILE"
  fi

  export ANDROID_HOME=$HOME/android-sdk
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"

  mkdir -p $ANDROID_HOME/licenses/
  echo > $ANDROID_HOME/licenses/android-sdk-license
  echo -n 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license

  installsdk 'build-tools;25.0.3' 'platforms;android-23' 'platforms;android-25' 'ndk-bundle' 'extras;android;m2repository'
}
