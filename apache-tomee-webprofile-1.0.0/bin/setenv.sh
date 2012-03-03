#!/bin/sh

# [environment]
JAVA_HOME=/usr/java/jdk1.6.0_29/
ANT_HOME=/home/crxnsink/opt/apache-ant-1.8.2

export JAVA_HOME
export ANT_HOME




# [openCRX]
export JAVA_OPTS="$JAVA_OPTS -Xmx800M"
export JAVA_OPTS="$JAVA_OPTS -XX:MaxPermSize=256m"
export JAVA_OPTS="$JAVA_OPTS -Djava.protocol.handler.pkgs=org.openmdx.kernel.url.protocol"
export JAVA_OPTS="$JAVA_OPTS -Dorg.opencrx.maildir=$CATALINA_BASE/maildir"
export JAVA_OPTS="$JAVA_OPTS -Dorg.opencrx.airsyncdir=$CATALINA_BASE/airsyncdir"
# export JAVA_OPTS="$JAVA_OPTS -Dorg.openmdx.persistence.jdbc.useLikeForOidMatching=false"
export CLASSPATH=$CLASSPATH:$CATALINA_BASE/bin/openmdx-system.jar
# [openCRX]

# [openCRX META-INF/context.xml configuration]
# export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.driverName=org.hsqldb.jdbcDriver"
# export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.url=jdbc:hsqldb:hsql://127.0.0.1:9001/CRX"
# export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.userName=sa"
# export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.password=manager99"
# [openCRX META-INF/context.xml configuration]

# [openCRX META-INF/context.xml configuration]
export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.driverName=com.mysql.jdbc.Driver"
export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.url=jdbc:mysql://127.0.0.1:3306/crxdev"
export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.userName=crxnsink"
export JAVA_OPTS="$JAVA_OPTS -Dopencrx.CRX.jdbc.password=jeremy-2008!!"
# [openCRX META-INF/context.xml configuration]




echo "Using JAVA_OPTS:       $JAVA_OPTS"
