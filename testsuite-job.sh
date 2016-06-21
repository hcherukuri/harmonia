if [ ! -z "${UPSTREAM_BUILD_URL}"  ]; then
    ARCHIVE_URL="${JENKINS_URL}/job/${PARENT_JOB_NAME}/lastSuccessfulBuild/artifact/*zip*/archive.zip"
else
    ARCHIVE_URL="${UPSTREAM_BUILD_URL}/artifact/*zip*/archive.zip"
fi

archive=$(mktemp)
wget --auth-no-challenge --user "${JENKINS_USERNAME}" --password "${JENKINS_PASSWORD}" -nv "${ARCHIVE_URL}" -O "${archive}"
unzip -q "${archive}" -d archive
rm "${archive}"
cd archive
mv * ..
cd ..
rmdir archive


. /opt/jboss-set-ci-scripts/common_bash.sh
set_ip_addresses
kill_jboss

which java
java -version

LOCAL_REPO_DIR=$WORKSPACE/maven-local-repository

export MAVEN_OPTS="-Xmx1024m -Xms512m -XX:MaxPermSize=256m"
TESTSUITE_OPTS="-Dnode0=127.0.1.1 -Dnode1=127.0.2.1"
TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dsurefire.forked.process.timeout=90000"
TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dskip-download-sources -B"
TESTSUITE_OPTS="${TESTSUITE_OPTS} -Djboss.test.mixed.domain.dir=/opt/old-as-releases"
TESTSUITE_OPTS="${TESTSUITE_OPTS} -Dmaven.test.failure.ignore=true"

export MAVEN_OPTS="${MAVEN_OPTS} -Dmaven.repo.local=${LOCAL_REPO_DIR}"


cd testsuite
chmod +x ../tools/maven/bin/mvn
../tools/maven/bin/mvn clean
cd ..

chmod +x ./integration-tests.sh
./integration-tests.sh -DallTests ${TESTSUITE_OPTS}
