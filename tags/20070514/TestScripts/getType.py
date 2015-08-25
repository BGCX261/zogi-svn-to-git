#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print server.zogi.getTypeOfObject(10160)
print server.zogi.getTypeOfObject(11150)
print server.zogi.getTypeOfObject(10930)
print server.zogi.getTypeOfObject(40)
