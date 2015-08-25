#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.flagFavorites([480400])
print server.zogi.unflagFavorites(['29420', '21060', '10120', '27160', '31880'])

