docker run --rm \
    -p 8080:8080 \
    -p 50000:50000 \
    -u root \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:2.131
