#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred@localhost/zidestore/so/adam/')
pprint.pprint(server.zogi.getFavoritesByType("Contact", 0))
