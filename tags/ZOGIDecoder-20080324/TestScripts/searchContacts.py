#!/usr/bin/env python
import xmlrpclib

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
criteria1 = { }
criteria1['key'] = 'firstName'
criteria1['value'] = '%yser%'
criteria1['expression'] = 'ILIKE'
criteria2 = { }
criteria2['conjunction'] = 'OR'
criteria2['key'] = 'lastName'
criteria2['value'] = '%yser%'
criteria2['expression'] = 'ILIKE'
criteria3 = { } 
criteria3['conjunction'] = 'OR'
criteria3['key'] = 'phone.number'
criteria3['value'] = '616.581.8010'
criteria3['expression'] = 'EQUALS'
#query = [ criteria3 ]
query = [ criteria1, criteria2 ]
flags = { 'limit' : 50,
          'revolve' : 'NO' }
result = server.zogi.searchForObjects('Contact', query, 65535, flags)
for contact in result:
  print "ObjectId#%d (%s)" % (contact['objectId'], contact['entityName'])


