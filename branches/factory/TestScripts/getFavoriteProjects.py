#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.getFavoritesByType('Project', 65535)
