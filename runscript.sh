#!/bin/sh

function showhelp {
  echo "Usage: $0 start|stop|restart|kill"
}

thin='thin -C conf/thin.conf.yml'

action=$1

case "$action" in
  'start')
    $thin start
    ;;
  'stop')
    $thin stop
    ;;
  'restart')
    $thin restart
    ;;
  'kill')
    pid=`cat tmp/allisdown.6006.pid`
    kill -9 $pid
    rm 'tmp/allisdown.6006.pid'
    echo "Thin server killed (if it has been run before)."
    ;;
  *)
    echo "Unknown option."
    showhelp
    ;;
esac
