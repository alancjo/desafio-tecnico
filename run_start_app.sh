if ! docker image inspect locaweb >/dev/null 2>&1; then
    docker build -t locaweb .
fi

if ! docker container inspect locaweb-container >/dev/null 2>&1; then
    docker run -itd --name locaweb-container locaweb
else
    docker start locaweb-container
fi

docker exec -it locaweb-container ruby ./input_interface/view/atm/home.rb
