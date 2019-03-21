BASEDIR=$(dirname "$0")
cd $BASEDIR
./gradlew test -Pserver=${COMMANDER_SERVER} -Ppassword=${COMMANDER_PASSWORD} $@
# --tests=com.electriccloud.plugin.spec.backup
