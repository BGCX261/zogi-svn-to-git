#!/bin/sh

cp -pvR /home/awilliam/Works/zogi/zOGI.zsp \
  /usr/local/lib/zidestore-1.5/
rcogo-zidestore restart
#tail -f /var/log/opengroupware/ogo-zidestore-1.5-err.log
