#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
contact = server.zogi.getObjectById(10363, 8)
contact['_ADDRESSES'][0]['name1'] = 'name1'
contact['_ADDRESSES'][0]['name2'] = 'name2'
contact['_ADDRESSES'][0]['name3'] = 'name3'
contact['_ADDRESSES'][0]['street'] = 'street'
contact['_ADDRESSES'][0]['city'] = 'city'
contact['_ADDRESSES'][0]['state'] = 'state'
contact['_ADDRESSES'][0]['zip'] = 'zip'
contact['_ADDRESSES'][0]['country'] = 'country'
contact = server.zogi.putObject(contact)
contact = server.zogi.getObjectById(10363, 8)
pprint.pprint(contact)
