#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost:21000/zidestore/so/adam/')
contact = server.zogi.getObjectById(10100, 520)
contact['_ADDRESSES'][0]['name1'] = 'name1'
contact['_ADDRESSES'][0]['name2'] = 'name2'
contact['_ADDRESSES'][0]['name3'] = 'name3'
contact['_ADDRESSES'][0]['street'] = 'street'
contact['_ADDRESSES'][0]['city'] = 'city'
contact['_ADDRESSES'][0]['state'] = 'state'
contact['_ADDRESSES'][0]['zip'] = 'zip'
contact['_ADDRESSES'][0]['country'] = 'country'
contact['_ENTERPRISES'] = [ { 'targetObjectId': 10290 }, { 'targetObjectId': 11387735} ];
contact = server.zogi.putObject(contact)
contact = server.zogi.getObjectById(10100, 520)
pprint.pprint(contact['_ENTERPRISES'])
print
contact['_ENTERPRISES'] = [ { 'targetObjectId': 10290 },
                            { 'targetObjectId': 11387735},
                            { 'targetObjectId': 4153760} ]
contact = server.zogi.putObject(contact)
pprint.pprint(contact['_ENTERPRISES'])
print
contact['_ENTERPRISES'] = [ ]
contact = server.zogi.putObject(contact)
pprint.pprint(contact['_ENTERPRISES'])
print
contact['_ENTERPRISES'] = [ { 'targetObjectId': 10290 },
                            { 'targetObjectId': 11387735},
                            { 'targetObjectId': 4153760} ]
contact = server.zogi.putObject(contact)
pprint.pprint(contact['_ENTERPRISES'])
