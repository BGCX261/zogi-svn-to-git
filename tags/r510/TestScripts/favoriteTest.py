#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print server.zogi.flagFavorites(10000)
#pprint.pprint(server.zogi.getFavoritesByType("Contact", 0))
