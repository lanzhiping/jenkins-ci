#install rsync
apt update
apt install rsync
apt install vim

#copy ssh keys to docker
docker cp ~/.ssh/id_rsa containerid:/root/.ssh/
docker cp ~/.ssh/id_rsa.pub containerid:/root/.ssh/
docker cp ~/.ssh/known_hosts containerid:/root/.ssh/
