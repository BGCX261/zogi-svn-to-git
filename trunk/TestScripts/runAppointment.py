#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost:21000/zidestore/so/adam/')
# Setup participants
participant1 = {}
participant1['participantObjectId'] = 10100
participant1['role'] = 'CHAIR'
participant1['comment'] = 'This dude rocks'
participant2 = {}
participant2['participantObjectId'] = 10003
participant2['role'] = 'REQ-PARTICIPANT'
# Setup note
notation1 = {}
notation1['title'] = 'Title Of First Note'
notation1['content'] = 'Content of first appointment notation'
notation1['entityName'] = 'note'
notation1['objectId'] = 0
notation2 = {}
notation2['title'] = 'Title Of Second Note'
notation2['content'] = 'Content of second appointment notation'
notation2['entityName'] = 'note'
notation2['objectId'] = 0
app = { }
app['entityName'] = 'Appointment'
app['objectId'] = '0'
app['keywords'] = 'ZOGI'
app['comment'] = 'COMMENT COMMENT COMMENT'
app['start'] = '2007-02-18 13:00'
app['end'] = '2007-02-18 15:00'
app['title'] = 'My New 2007 Appointment'
app['location'] = 'Sardinia'
app['notification'] = 10
app['_NOTES'] = [ notation1 ]
app['_RESOURCES'] = [ { 'objectId': 465950 }, { 'objectId': 465990 } ]
app['_FLAGS'] = 'ignoreConflicts'
app['_PARTICIPANTS'] = [ participant1, participant2 ]
app['readAccessTeamObjectId'] = 10003
app['timeZone'] = 'EST'
app['priorDuration'] = 45
print "--Create--"
app = server.zogi.putObject(app)
pprint.pprint(app)
print "--Put Note ---"
app['_NOTES'] = [ app['_NOTES'][0], notation2 ]
app['_FLAGS'] = 'ignoreConflicts'
app['_PARTICIPANTS'] = [ participant1, participant2 ]
app = server.zogi.putObject(app)
pprint.pprint(app)

print "--Update, updating note--"
print "objectId: %s" % app['objectId']
app['title'] = 'Modified Appointment'
app['notification'] =  120
app['_FLAGS'] = 'ignoreConflicts'
app['_PARTICIPANTS'] = [ participant2 ]
app['_RESOURCES'] = [ { 'objectId': 465990 } ]
app['_NOTES'][0]['title'] = 'Updated note title'
app['_NOTES'][0]['content'] = 'Updated content of note'
app['readAccessTeamObjectId'] = 0
app['writeAccessObjectIds'] = [ 10003, 10100 ];
app['priorDuration'] = 15
app['postDuration'] = 50
app = server.zogi.putObject(app)
pprint.pprint(app)

print "--Update, erasing notes--"
app['_NOTES'] = [ app['_NOTES'][0] ];
app['_FLAGS'] = 'ignoreConflicts'
app['_RESOURCES'] = [  ]
app['writeAccessObjectIds'] = []
app = server.zogi.putObject(app)
pprint.pprint(app)

print "--Update, adding properties--"
property1 = {}
property1['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myIntAttribute'
property1['value'] = 7
property2 = {}
property2['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myStringAttribute'
property2['value'] = 'Hi there'
app['_PROPERTIES'] = [ property1, property2 ]
app['_FLAGS'] = 'ignoreConflicts'
app = server.zogi.putObject(app)
pprint.pprint(app)

print "--Update, changing properties--"
property1 = {}
property1['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myIntAttribute'
property1['value'] = 4
property2 = {}
property2['namespace'] = 'http://www.whitemiceconsulting.com/properties/ext-attr'
property2['attribute'] = 'myStringAttribute'
property2['value'] = 'Ho there'
app['_PROPERTIES'] = [ property1, property2 ]
app['_FLAGS'] = 'ignoreConflicts'
app = server.zogi.putObject(app)
pprint.pprint(app)

print "--Update, deleting property--"
app['_PROPERTIES'] = [ app['_PROPERTIES'][1] ]
app['_RESOURCES'] = [ { 'objectId': 465950 }, { 'objectId': 465990 } ]
app['_FLAGS'] = 'ignoreConflicts'
app = server.zogi.putObject(app)
pprint.pprint(app)


print "--Get--"
pprint.pprint(server.zogi.getObjectById(app['objectId'], 65535))
print "--GetVersion--"
print server.zogi.getObjectVersionsById(app['objectId'])
print "--Delete--"
app = server.zogi.deleteObject(app, ['deleteCycle'])
pprint.pprint(app)
print
#print "--Get deleted appointment--"
#print server.zogi.getObjectById(app['objectId'])
