#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://root:fred@192.168.3.164/zidestore/so/root/')
#print "archived"
#pprint.pprint(server.zogi.searchForObjects('Task', "archived" ,65535))
print "todo"
pprint.pprint(server.zogi.searchForObjects('Task', "todo" , 19))
#print "delegated"
#pprint.pprint(server.zogi.searchForObjects('Task', "delegated" ,65535))
