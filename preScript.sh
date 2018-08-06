#install rsync
apt update
apt install rsync

#copy ssh keys to docker
docker cp ./id_rsa containerid:/root/.ssh/
docker cp ./id_rsa.pub containerid:/root/.ssh/
