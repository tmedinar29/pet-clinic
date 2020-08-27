#!/bin/bash

start_test()
{
    docker start -a selenium-testsuite
}


stop_test()
{
    set +e
    docker rm -f selenium-testsuite
    set -e
}

rebuild_test()
{
    docker rm -f selenium-testsuite
    docker pull devopsdojo/selenium-yb:latest
    docker create --name="selenium-testsuite" devopsdojo/selenium-yb:latest
    sed '3q;d' /tmp/shortname.txt | sed 's/8080/9966/1' | xargs -I 'my_arg' sed -i 's#http://petclinic#my_arg#' src/test/selenium-robot/resources/resource.robot
    sleep 2s
    docker cp src/test/selenium-robot/PetclinicTestCases selenium-testsuite:/home/robotframework/src/test/selenium-robot
    docker cp src/test/selenium-robot/resources selenium-testsuite:/home/robotframework/src/test/selenium-robot
}

echo 'Invoking automated test cases in docker ' 
echo 'Stop the docker container'
stop_test
echo 'Build the docker selenium container'  
rebuild_test
echo 'Start docker container' 
start_test
echo 'Create report directory' 
set +e
rm -rf report
set -e
mkdir report
echo 'Copy test cases report from docker container'
docker cp selenium-testsuite:home/robotframework/src/test/selenium-robot/output.xml report
docker cp selenium-testsuite:home/robotframework/src/test/selenium-robot/log.html report
docker cp selenium-testsuite:home/robotframework/src/test/selenium-robot/report.html report