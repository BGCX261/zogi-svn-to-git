#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
#pprint.pprint(server.zogi.getObjectById(10003, 0))
pprint.pprint(server.zogi.getObjectById(12896300, 65535))
#pprint.pprint(server.zogi.getObjectById(10003, 65535))
#pprint.pprint(server.zogi.getObjectById(6602750, 0))
#pprint.pprint(server.zogi.getObjectById(7438300, 0))
#pprint.pprint(server.zogi.getObjectById(10100, 0))
#pprint.pprint(server.zogi.getObjectById(1287540, 65535))
#pprint.pprint(server.zogi.getObjectById(11585570, 65535))
