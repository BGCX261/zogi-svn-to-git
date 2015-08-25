#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
print server.zogi.flagFavorites(10000)
#pprint.pprint(server.zogi.getFavoritesByType("Contact", 0))
