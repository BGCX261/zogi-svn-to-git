#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
contact = { }
contact['firstName'] = 'Fred'
contact['lastName'] = 'Smith'
contact['entityName'] = 'Contact'
contact['objectId'] = 0
contact['birthDate'] = '1972-12-06'
companyValue = {}
companyValue['attribute'] = 'salesperson'
companyValue['value'] = [1,2,3]
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
contact['gender'] = 'male'
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
tel1 = {}
tel1['type'] = '01_tel'
tel1['number'] = '123.456.4567'
tel1['info'] = 'Troop Ships!'
tel2 = {}
tel2['type'] = '10_fax'
tel2['number'] = '1234'
tel3 = {}
tel3['type'] = '03_tel_funk'
tel3['number'] = '1234'
contact['gender'] = 'undefined'
contact['salutation'] = '10_dear_ms'
companyValue['attribute'] = 'email2'
companyValue['value'] = 'fred@backbone.local'
contact['birthDate'] = ''
acl2['operations'] = 'rw'
acl1['operations'] = ''
contact['_COMPANYVALUES'] = [ companyValue ]
contact['_PROPERTIES'] = [ property2 ]
contact['_ACCESS'] = [ acl2, acl1 ]
contact['_FLAGS'] = [ 'ignoreVersion' ]
contact['_PHONES'] = [ tel1, tel2, tel3 ]
contact = server.zogi.putObject(contact)
pprint.pprint(contact)
print
print
print "--DELETE Contact--"
pprint.pprint(server.zogi.deleteObject(contact['objectId']))
print
print "--Get deleted contact--"
print server.zogi.getObjectById(contact['objectId'])
