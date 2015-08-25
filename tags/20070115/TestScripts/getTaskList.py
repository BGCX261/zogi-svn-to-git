#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print "archived"
print server.zogi.searchForObjects('Task', "archived" ,65535);
print "todo"
print server.zogi.searchForObjects('Task', "todo" ,65535);
print "delegated"
print server.zogi.searchForObjects('Task', "delegated" ,65535);
