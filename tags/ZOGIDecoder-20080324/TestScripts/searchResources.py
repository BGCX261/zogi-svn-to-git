#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
flags = { 'limit' : 2 }
print
criteria = { }
criteria['category'] = 'Fred'
criteria['name'] = 'Grand Rapids'
print "Fuzzy Search - no flags"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0))
print
print "Fuzzy Search - w/flags"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0, flags))
print
criteria = { }
criteria['conjunction'] = 'AND'
criteria['category'] = 'Rooms'
print "Exact search - no flags"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0))
print
print "Exact search - w/flags"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0, flags))
print
criteria = { }
print "All Resources - no flags"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0))
print
print "All Resources - w/flags - should be only 2"
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 0, flags))
