#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print "archived"
print server.zogi.getTasksByList("archived", 65535)
print "todo"
print server.zogi.getTasksByList("todo", 65535)
print "delegated"
print server.zogi.getTasksByList("delegated", 65535)
