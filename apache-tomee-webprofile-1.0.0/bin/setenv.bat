REM [openCRX]
set JAVA_OPTS=%JAVA_OPTS% -Xmx800M 
set JAVA_OPTS=%JAVA_OPTS% -XX:MaxPermSize=256m
set JAVA_OPTS=%JAVA_OPTS% -Djava.protocol.handler.pkgs=org.openmdx.kernel.url.protocol
set JAVA_OPTS=%JAVA_OPTS% -Dorg.opencrx.maildir=%CATALINA_BASE%\maildir
set JAVA_OPTS=%JAVA_OPTS% -Dorg.opencrx.airsyncdir=%CATALINA_BASE%\airsyncdir
REM JAVA_OPTS=%JAVA_OPTS% -Dorg.openmdx.persistence.jdbc.useLikeForOidMatching=false
set "CLASSPATH=%CLASSPATH%;%CATALINA_BASE%\bin\openmdx-system.jar"
REM [openCRX]

REM [openCRX META-INF/context.xml configuration]
set JAVA_OPTS=%JAVA_OPTS% -Dopencrx.CRX.jdbc.driverName=org.hsqldb.jdbcDriver
set JAVA_OPTS=%JAVA_OPTS% -Dopencrx.CRX.jdbc.url=jdbc:hsqldb:hsql://127.0.0.1:9001/CRX
set JAVA_OPTS=%JAVA_OPTS% -Dopencrx.CRX.jdbc.userName=sa
set JAVA_OPTS=%JAVA_OPTS% -Dopencrx.CRX.jdbc.password=manager99
REM [openCRX META-INF/context.xml configuration]

echo Using JAVA_OPTS:       "%JAVA_OPTS%"
