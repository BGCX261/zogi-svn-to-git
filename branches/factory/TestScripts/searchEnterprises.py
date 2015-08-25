#!/usr/bin/env python
import xmlrpclib,pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
criteria1 = { }
criteria1['conjunction'] = 'OR'
criteria1['key'] = 'name'
criteria1['value'] = '%equipment%'
criteria1['expression'] = 'ILIKE'
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
query = [ criteria1 ]
flags = { 'limit' : 150,
          'revolve': 'NO' }
result = server.zogi.searchForObjects('Enterprise', query, 520, flags)
##for enterprise in result:
##  print 'Enterprise#%d : %s' % (enterprise['objectId'], enterprise['entityName'])


