#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.getTypeOfObject(10160)
print server.zogi.getTypeOfObject(11150)
print server.zogi.getTypeOfObject(10930)
print server.zogi.getTypeOfObject(40)
print server.zogi.getTypeOfObject(11156938)
