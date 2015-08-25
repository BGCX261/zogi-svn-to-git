#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.getObjectVersionsById([29420, 21060, 10120, 480400])
