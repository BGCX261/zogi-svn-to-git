#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria1 = { }
criteria1['conjunction'] = 'OR'
criteria1['key'] = 'firstName'
criteria1['value'] = 'Adam%'
criteria1['expression'] = 'LIKE'
criteria2 = { } 
criteria2['conjunction'] = 'OR'
criteria2['key'] = 'lastName'
criteria2['value'] = 'FRED'
criteria2['expression'] = 'LIKE'
criteria3 = { } 
criteria3['conjunction'] = 'AND'
criteria3['key'] = 'city'
criteria3['value'] = 'Grand Rapids'
criteria3['expression'] = 'EQUALS'
#query = [ criteria1, criteria2, criteria3 ]
query = [ criteria1 ]
pprint.pprint(server.zogi.searchForObjects('Contact', query ,65535))

