if ! docker image inspect locaweb >/dev/null 2>&1; then
    docker build -t locaweb .
fi

docker run -it locaweb bash
