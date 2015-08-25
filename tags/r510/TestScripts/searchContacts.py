#!/usr/bin/env python
import xmlrpclib

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria1 = { }
criteria1['conjunction'] = 'OR'
criteria1['key'] = 'email1'
criteria1['value'] = '%@whitemice.org'
criteria1['expression'] = 'LIKE'
criteria3 = { }
criteria2 = { }
criteria2['conjunction'] = 'AND'
criteria2['key'] = 'address.city'
criteria2['value'] = 'Grand Rapids'
criteria2['expression'] = 'LIKE'
criteria3 = { } 
criteria3['conjunction'] = 'OR'
criteria3['key'] = 'phone.number'
criteria3['value'] = '616.581.8010'
criteria3['expression'] = 'EQUALS'
query = [ criteria3 ]
#query = [ criteria1, criteria2, criteria3 ]
result = server.zogi.searchForObjects('Contact', query, 0)
for contact in result:
  print "ObjectId#%d (%s, %s)" % (contact['objectId'], contact['lastName'], contact['firstName'])


