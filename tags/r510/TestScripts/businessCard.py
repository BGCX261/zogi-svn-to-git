#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
enterprise = { }
enterprise['name'] = 'Fred Inc.'
enterprise['entityName'] = 'Enterprise'
enterprise['objectId'] = 0
address1 = {}
address1['name1'] = 'Fred Smith'
address1['street'] = '1234 Elm St.'
address1['city'] = 'Pandemonium'
address1['type'] = 'bill'
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
person['firstName'] = 'Adam'
person['lastName'] = 'Williams'
address2 = {}
address2['name1'] = 'Fred Smith'
address2['street'] = '1234 Elm St.'
address2['city'] = 'Pandemonium'
address2['type'] = 'location'
companyValue = {}
companyValue['attribute'] = 'email2'
companyValue['value'] = 'fred@example.com'
person['_COMPANYVALUES'] = [ companyValue ]
person['_ADDRESSES'] = [ address2 ]
person['_PHONES'] = [ phone ]
person['_ACCESS'] = [ acl1, acl2 ]

enterprise['_FLAGS'] = 'businessCard'
enterprise['_PHONES'] = [ phone ]
enterprise['_CONTACTS'] = [ person ]
enterprise['_ADDRESSES'] = [ address1 ]
enterprise['_ACCESS'] = [ acl1, acl2 ]
print "--PUT Enterprise (New)--"
enterprise = server.zogi.putObject(enterprise)
pprint.pprint(enterprise)
