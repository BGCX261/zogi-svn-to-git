#!/usr/bin/env python
import xmlrpclib,pprint

server = xmlrpclib.Server('http://adam:******@localhost/zidestore/so/adam/')
criteria1 = { }
criteria1['conjunction'] = 'OR'
criteria1['key'] = 'email2'
criteria1['value'] = '%handling%'
criteria1['expression'] = 'ILIKE'
query = [ criteria1,  ]
flags = { 'limit' : 150,
          'revolve': 'NO' }
result = server.zogi.searchForObjects('Enterprise', query, 0, flags)
for enterprise in result:
  print 'Enterprise#%d : %s' % (enterprise['objectId'], 
                                enterprise['name'])


