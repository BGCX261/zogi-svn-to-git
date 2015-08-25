#!/usr/bin/env python
import xmlrpclib, time

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria1 = { }
criteria1['conjunction'] = 'AND'
criteria1['key'] = 'firstName'
criteria1['value'] = 'Adam'
criteria1['expression'] = 'EQUALS'
criteria2 = { } 
criteria2['conjunction'] = 'AND'
criteria2['key'] = 'lastName'
criteria2['value'] = 'W'
criteria2['expression'] = 'LIKE'
query = [ criteria1, criteria2 ]
print server.zogi.searchForObjects('Person', query ,65535);

