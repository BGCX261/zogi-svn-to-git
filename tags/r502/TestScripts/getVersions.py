#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print server.zogi.getObjectVersionsById([29420, 21060, 10120, 480400])
