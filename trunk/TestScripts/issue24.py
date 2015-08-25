#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
# Setup participants
participant1 = {}
participant1['participantObjectId'] = 10100
participant1['status'] = 'ACCEPTED'
participant1['role'] = 'REQ-PARTICIPANT'
# Setup note
app = {}
app['entityName'] = 'Appointment'
app['objectId'] = 11148230
app['comment'] = ''
app['start'] = '2008-03-25 22:00'
app['end'] = '2008-03-25 23:00'
app['title'] = 'JTitle'
app['location'] = 'CBS Ch#3'
app['notification'] = 360
app['isConflictDisabled'] = 0
app['_FLAGS'] = 'ignoreConflicts'
app['_PARTICIPANTS'] = [ participant1 ]
app['readAccessTeamObjectId'] = 0
app['writeAccessObjectIds'] = ''
app['timeZone'] = 'EST'
print "--Update--"
app = server.zogi.putObject(app)
pprint.pprint(app) 

