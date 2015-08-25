#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print "getACLById(int=10120)"
print server.zogi.getACLsForObjectId(28310)
print server.zogi.getACLsForObjectId("27160")
print server.zogi.getACLsForObjectId([ "27160", 10120, 28310, "28210" ])
