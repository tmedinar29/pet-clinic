pipeline {
    agent none
    stages {
        stage('Compile and Test') {
            agent any
            steps {
                sh "mvn --batch-mode package" 
            }
        }

        stage('Publish Tests Results') {
            agent any
            steps {
               echo 'Archive Unit Test Results'
               step([$class: 'JUnitResultArchiver', testResults: 'target/surefire-reports/TEST-*.xml'])
            }
        }
        
        stage('Create and Publish Docker Image'){
            agent any
            steps{
                script {
                    env.GITHUB_USER = sh(script: "sed -n '1p' /tmp/shortname.txt",returnStdout: true).trim()
                    env.SHORT_COMMIT= env.GIT_COMMIT[0..7]
                    env.TAG_NAME="docker.pkg.github.com/$GITHUB_USER/pet-clinic/petclinic:$SHORT_COMMIT".toLowerCase()
                }
                sh "docker build -t $TAG_NAME -f Dockerfile.deploy ."
                sh "sed -n '2p' /tmp/shortname.txt | docker login https://docker.pkg.github.com -u $GITHUB_USER --password-stdin"
                sh "docker push $TAG_NAME"
            }
        }

        stage('Deploy Development') {
            agent any
            steps {
                sh '''
                    for runName in `docker ps | grep "alpine-petclinic-dev" | awk '{print $1}'`
                    do
                        if [ "$runName" != "" ]
                        then
                            docker stop $runName
                        fi
                    done
                    docker run --name alpine-petclinic-dev --rm -d -p 9966:8080 $TAG_NAME
                '''
            }
        }
        stage('Decide Deploy to Test'){
        when {
            branch 'master'
            }
            agent none
            steps {
                input message: 'Deploy to Test?'
            }            
        }
        stage('Deploy Test'){
            when {
                branch 'master'
            }
            agent any
            steps {
                sh '''
                    for runName in `docker ps | grep "alpine-petclinic-test" | awk '{print $1}'`
                    do
                        if [ "$runName" != "" ]
                        then
                            docker stop $runName
                        fi
                    done
                    docker run --name alpine-petclinic-test --rm -d -p 9967:8080 $TAG_NAME
                '''
            }
        }
        stage("End to End Tests") {
            when {
                branch 'master'
            }
            agent any
            steps {
                sh "chmod +x robot.sh"
                sh "./robot.sh"
            }
}    

    }
}
