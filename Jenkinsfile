pipeline {
    agent any

    tools {
        nodejs "Node10"
    }

    parameters {
        choice choices: ["", "BUMP", "PATCH", "PROD", "MANUAL"], description: "Please select a task", name: "TASK"
        string defaultValue: "", description: "Please select a branch version. eg: 2.0, 2.1, 2.2. If you want to manually deploy, please input whole branch name(master/ release/v3.3.1).", name: "PATCH_VERSION", trim: false
        choice choices: ["dev", "sit", "uat"], description: "Please select a environment to deploy", name: "DEPLOY_ENV"
    }

    stages {
        stage("Setup") {
            parallel {
                stage("BUMP") {
                    when {
                        environment name: "TASK", value: "BUMP"
                    }
                    steps {
                        withCredentials([sshUserPrivateKey(credentialsId: "ge-github-credential", keyFileVariable: "SSH_KEY")]) {
                            sh "bash scripts/bump.sh"
                        }
                    }
                }

                stage("PATCH") {
                    when {
                        environment name: "TASK", value: "PATCH"
                    }
                    steps {
                        withCredentials([sshUserPrivateKey(credentialsId: "ge-github-credential", keyFileVariable: "SSH_KEY")]) {
                            sh "bash scripts/patch.sh ${PATCH_VERSION}"
                            sh "git checkout release/v${PATCH_VERSION}"
                        }
                    }
                }

                stage("PROD") {
                    when {
                        environment name: "TASK", value: "PROD"
                    }
                    steps {
                        withCredentials([sshUserPrivateKey(credentialsId: "ge-github-credential", keyFileVariable: "SSH_KEY")]) {
                            sh "bash scripts/tag.sh ${PATCH_VERSION}"
                            sh "git checkout release/v${PATCH_VERSION}"
                        }
                    }
                }

                stage("MANUAL") {
                    when {
                        environment name: "TASK", value: "MANUAL"
                    }
                    steps {
                        withCredentials([sshUserPrivateKey(credentialsId: "ge-github-credential", keyFileVariable: "SSH_KEY")]) {
                            sh "git checkout origin/${PATCH_VERSION}"
                        }
                    }
                }
            }
        }


        stage("Build") {
            steps {
                sh "npm install -g yarn"
                sh "yarn"
                sh "yarn lint"
                sh "yarn test"
                sh "yarn build"
            }
        }

        stage("Artifact") {
            when {
                environment name: "TASK", value: "PROD"
            }
            steps {
                sh "bash scripts/addArtifactsToGithub.sh ${env.GH_ACCESS_TOKEN}"
            }
        }

        stage("Deploy") {
            steps {
                sh "bash scripts/deploy.sh ${DEPLOY_ENV}"
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeeded!"
        }

        failure {
            echo "Pipeline failed"
        }
    }
}
