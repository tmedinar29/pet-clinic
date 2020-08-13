pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Build'
                sh "mvn --batch-mode package" 
            }
        }

        stage('Publish Tests Results') {
            steps {
               echo 'Archive Unit Test Results'
               step([$class: 'JUnitResultArchiver', testResults: 'target/surefire-reports/TEST-*.xml'])
            }
        }
        
        stage('Create and Publish Docker Image'){
            steps{
                script {
                    env.GITHUB_USER = sh(script: "sed -n '1p' /tmp/shortname.txt",returnStdout: true).trim()
                    env.SHORT_COMMIT= env.GIT_COMMIT[0..7]
                    env.TAG_NAME="docker.pkg.github.com/$GITHUB_USER/pet-clinic/petclinic:$SHORT_COMMIT"
                }
                sh "docker build -t $TAG_NAME -f Dockerfile.deploy ."
                sh "sed -n '2p' /tmp/shortname.txt | docker login https://docker.pkg.github.com -u $GITHUB_USER --password-stdin"
                sh "docker push $TAG_NAME"
            }
        }

        stage('Deploy Development') {
            steps {
                echo 'Deploy'
                sh '''
                    for runName in `docker ps | grep "alpine-petclinic" | awk '{print $1}'`
                    do
                        if [ "$runName" != "" ]
                        then
                            docker stop $runName
                        fi
                    done
                    docker run --name alpine-petclinic --rm -d -p 9966:8080 $TAG_NAME
                '''
            }
        }           
    }
}