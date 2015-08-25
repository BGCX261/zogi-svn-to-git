#!/usr/bin/env python
import xmlrpclib,pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
criteria1 = { }
criteria1['key'] = 'firstName'
criteria1['value'] = '%dam%'
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
flags = { 'limit' : 25, 'filter' : '(isAccount = 1)' }
#flags = { }
result = server.zogi.searchForObjects('Contact', query, 32768, flags)
for contact in result:
  print(contact)
  print
