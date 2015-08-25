#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.getFavoritesByType("Enterprise", 65535)
