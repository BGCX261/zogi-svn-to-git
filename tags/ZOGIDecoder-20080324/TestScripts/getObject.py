#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:Kador23@gourd-amber/zidestore/so/adam/')
#pprint.pprint(server.zogi.getObjectById(10003, 0))
#pprint.pprint(server.zogi.getObjectById(10100, 65535))
#pprint.pprint(server.zogi.getObjectById(10003, 65535))
#pprint.pprint(server.zogi.getObjectById(6602750, 0))
#pprint.pprint(server.zogi.getObjectById(7438300, 0))
#pprint.pprint(server.zogi.getObjectById(10100, 0))
#pprint.pprint(server.zogi.getObjectById(804330, 0))
pprint.pprint(server.zogi.getObjectById(10418682, 8))
