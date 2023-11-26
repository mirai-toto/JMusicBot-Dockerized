#!/bin/sh

# JMusicBot Release Github URL
RELEASE_URL="https://api.github.com/repos/jagrosh/MusicBot/releases/latest"

# Flags for downloading and looping
DOWNLOAD=true
LOOP=false
DOCKERIZE=true
PATH_OF_SCRIPT=$0
DIR_PATH=$(dirname "$PATH_OF_SCRIPT")

check_dependencies() {
    for cmd in docker curl jq; do
        if [ -z "$(command -v ${cmd})" ]; then
            echo "Error: $cmd is not installed." >&2
            exit 1
        fi
    done
}

check_docker_running() {
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker is not running." >&2
        exit 1
    fi
}

stop_container() {
    echo "Stopping JMusicBot..."
    local _stopped=false
    local _removed=false

    if docker stop jmusicbot >/dev/null 2>&1; then
        echo "jmusicbot container stopped."
        _stopped=true
    else
        echo "No jmusicbot container to stop."
    fi

    if docker rmi jmusicbot >/dev/null 2>&1; then
        echo "jmusicbot image deleted."
        _removed=true
    else
        echo "No jmusicbot image to delete."
    fi

    if [ "$_stopped" = false ] && [ "$_removed" = false ]; then
        return 1
    fi
}

launch_container() {
    echo "Launching JMusicBot..."
    if ! docker images | grep -qw jmusicbot; then
        echo "Building jmusicbot Docker image..."
        echo "Building image from directory: $DIR_PATH"
        if ! docker build --build-arg JMUSICBOT_VERSION="$JMUSICBOT_VERSION" -t jmusicbot $DIR_PATH >/dev/null 2>&1; then
            echo "Failed to build jmusicbot Docker image." >&2
            exit 1
        fi
    fi

    if ! docker ps -a --format '{{.Names}}' | grep -qw jmusicbot; then
        echo "Running jmusicbot Docker container..."
        if ! docker run --name jmusicbot --rm -d jmusicbot >/dev/null; then
            echo "Failed to run jmusicbot container." >&2
            exit 1
        fi
        echo "jmusicbot container started."
    else
        echo "jmusicbot container already exists."
    fi
}

download_latest_release() {
    if [ "$DOWNLOAD" = "true" ]; then
        URL=$(curl -s "$RELEASE_URL" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')
        if [ -z "$URL" ]; then
            echo "Error: Unable to find the JAR URL in the release data." >&2
            exit 1
        fi
        # Extract the version from the URL
        JMUSICBOT_VERSION=$(echo "$URL" | grep -oP 'JMusicBot-\K[\d\.]+(?=\.jar)')
        FILENAME=$(basename "$URL")
        if [ ! -f "$DIR_PATH/$FILENAME" ]; then
            echo "Downloading latest version: $FILENAME"
            if ! curl -L "$URL" -o "$DIR_PATH/$FILENAME"; then
                echo "Failed to download $FILENAME" >&2
                exit 1
            fi
            [ "$DOCKERIZE" = "true" ] && stop_container
        else
            echo "Latest version already downloaded (${FILENAME})"
        fi
    fi
}

run_bot() {
    JAVA_CMD=$(find $DIR_PATH -name "JMusicBot*.jar" -print | head -1)
    if [ -z "$JAVA_CMD" ]; then
        echo "No JMusicBot jar found." >&2
        exit 1
    fi
    if [ "$DOCKERIZE" = "true" ]; then
        launch_container "$JMUSICBOT_VERSION"
    else
        java -Dnogui=true -jar "$JAVA_CMD"
    fi
}

start() {
    while :; do
        download_latest_release
        run_bot
        [ "$LOOP" != "true" ] && break
        sleep 10
    done
}

usage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --stop  Stop and remove the JMusicBot Docker container"
    echo "  No options will start the JMusicBot process"
    echo "Example:"
    echo "  $0        # Start the JMusicBot"
    echo "  $0 --stop # Stop and remove the JMusicBot container"
}

parseArgs() {
    case "$1" in
    --stop)
        stop_container
        ;;
    --help)
        usage
        ;;
    *)
        if [ $# -eq 0 ]; then
            start
        else
            usage
        fi
        ;;
    esac
}

main() {
    check_dependencies
    check_docker_running
    parseArgs "$@"
}

main "$@"
