#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
contact = { }
contact['firstName'] = 'Fred'
contact['lastName'] = 'Smith'
contact['entityName'] = 'Contact'
contact['objectId'] = 0
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
enterprise = {}
enterprise['targetObjectId'] = 148730
contact['_ADDRESSES'] = [ address ]
contact['_PHONES'] = [ phone ]
contact['_COMPANYVALUES'] = [ companyValue ]
contact['_ENTERPRISES'] = [ enterprise ]
contact['_ACCESS'] = [ acl1, acl2 ]
property1 = {}
property1['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myIntAttribute'
property1['value'] = 7
property2 = {}
property2['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myStringAttribute'
property2['value'] = 'Hi there'
contact['_PROPERTIES'] = [ property1, property2 ]
print "--PUT Contact (New)--"
contact = server.zogi.putObject(contact)
pprint.pprint(contact)
print
print
print "--PUT Contact (Update)--"
companyValue['attribute'] = 'email2'
companyValue['value'] = 'fred@backbone.local'
acl2['operations'] = 'rw'
acl1['operations'] = ''
contact['_COMPANYVALUES'] = [ companyValue ]
contact['_PROPERTIES'] = [ property2 ]
contact['_ACCESS'] = [ acl2, acl1 ]
contact['_FLAGS'] = [ 'ignoreVersion' ]
contact = server.zogi.putObject(contact)
pprint.pprint(contact)
print
print
print "--DELETE Contact--"
pprint.pprint(server.zogi.deleteObject(contact['objectId']))
print
print "--Get deleted contact--"
print server.zogi.getObjectById(contact['objectId'])
