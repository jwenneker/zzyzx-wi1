#!/bin/sh

# START, RUN, or STOP openCRX Server
# ----------------------------

if [ "$1" = "run" ] ; then

  # Start HSQLDB
  if [ -e /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh ] ; then 
  #  /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh START &
    sleep 3
  fi

  # Start TomEE
  export JAVA_HOME=/usr/java/jdk1.6.0_29
  cd ..
  rm -Rf temp
  mkdir temp
  rm -Rf work
  ./bin/catalina.sh run

fi

if [ "$1" = "start" ] ; then

  # Start HSQLDB
  if [ -e /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh ] ; then
  #  /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh START &
    sleep 3
  fi

  # Start TomEE
  export JAVA_HOME=/usr/java/jdk1.6.0_29
  cd ..
  rm -Rf temp
  mkdir temp
  rm -Rf work
  ./bin/catalina.sh start

fi




if [ "$1" = "stop" ] ; then

  # Stop HSQLDB
  if [ -e /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh ] ; then 
  #  /home/crxnsink/opencrx-2.9.0//data/crx/startdb.sh STOP
  sleep 3
  fi
  
  # Stop TomEE
  cd ..
  ./bin/catalina.sh stop

fi
