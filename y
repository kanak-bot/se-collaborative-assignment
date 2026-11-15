scripted pipeline: 

pipeline {
    agent any

    tools {
        maven 'MAVEN_HOME'
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {

        stage('Git Repository and Clean') {
            steps {
                deleteDir()

                dir('mavenjava') {
                    git branch: 'main',
                        url: 'https://github.com/kabrakanak26-pixel/Week4-Maven-Lab.git'

                    dir('my-manven-project') {
                        bat 'mvn clean'
                    }
                }
            }
        }

        stage('Install') {
            steps {
                dir('mavenjava/my-manven-project') {
                    bat 'mvn install'
                }
            }
        }

        stage('Test') {
            steps {
                dir('mavenjava/my-manven-project') {
                    bat 'mvn test'
                }
            }
        }

        stage('Package') {
            steps {
                dir('mavenjava/my-manven-project') {
                    bat 'mvn package'
                }
            }
        }
    }
}
