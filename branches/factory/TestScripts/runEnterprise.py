#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
enterprise = { }
enterprise['name'] = 'Fred Inc.'
enterprise['entityName'] = 'Enterprise'
enterprise['objectId'] = 0
companyValue = {}
companyValue['attribute'] = 'email2'
companyValue['value'] = 'fred@example.com'
address = {}
address['name1'] = 'Fred Smith'
address['street'] = '1234 Elm St.'
address['city'] = 'Pandemonium'
address['type'] = 'private'
phone = {}
phone['type'] = '01_tel'
phone['number'] = '6163401149'
phone['info'] = 'Old number'
acl1 = {}
acl1['targetObjectId'] = 10160
acl1['operations'] = 'rw'
acl2 = {}
acl2['targetObjectId'] = 10003
acl2['operations'] = 'r'
person = {}
person['targetObjectId'] = 10160
enterprise['_ADDRESSES'] = [ address ]
enterprise['_PHONES'] = [ phone ]
enterprise['_COMPANYVALUES'] = [ companyValue ]
enterprise['_CONTACTS'] = [ person ]
enterprise['_ACCESS'] = [ acl1, acl2 ]
property1 = {}
property1['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myIntAttribute'
property1['value'] = 7
property2 = {}
property2['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myStringAttribute'
property2['value'] = 'Hi there'
enterprise['_PROPERTIES'] = [ property1, property2 ]
print "--PUT Enterprise (New)--"
enterprise = server.zogi.putObject(enterprise)
pprint.pprint(enterprise)
print
print
print "--GET Enterprise--"
pprint.pprint(server.zogi.getObjectById(enterprise['objectId'], 65535))
print
print
print "--PUT Enterprise (Update)--"
companyValue['attribute'] = 'email2'
companyValue['value'] = 'fred@backbone.local'
enterprise['_COMPANYVALUES'] = [ companyValue ]
enterprise['_PROPERTIES'] = [ property2 ]
enterprise = server.zogi.putObject(enterprise)
pprint.pprint(enterprise)
print
print
print "--GET Enterprise--"
pprint.pprint(server.zogi.getObjectById(enterprise['objectId'], 65535))
print
print
print "--DELETE Enterprise--"
pprint.pprint(server.zogi.deleteObject(enterprise['objectId']))
print
print "--Get deleted enterprise--"
print server.zogi.getObjectById(enterprise['objectId'])
