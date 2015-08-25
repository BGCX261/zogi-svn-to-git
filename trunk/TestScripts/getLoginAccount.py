#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
pprint.pprint(server.zogi.getLoginAccount(128))
print
pprint.pprint(server.zogi.getLoginAccount(65535))
