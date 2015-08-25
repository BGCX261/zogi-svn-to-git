#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print "archived"
pprint.pprint(server.zogi.searchForObjects('Task', "archived" ,65535))
print "todo"
pprint.pprint(server.zogi.searchForObjects('Task', "todo" ,65535))
print "delegated"
pprint.pprint(server.zogi.searchForObjects('Task', "delegated" ,65535))
