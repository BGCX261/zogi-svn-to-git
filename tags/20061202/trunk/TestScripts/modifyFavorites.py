#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
#print server.zogi.flagFavorites([29420, 21060, 10120])
print server.zogi.unflagFavorites(['29420', '21060', '10120', '27160', '31880'])

