#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
# Setup participants
participant1 = {}
participant1['participantObjectId'] = 10102
participant1['role'] = 'CHAIR'
participant1['comment'] = 'This dude rocks'
participant2 = {}
participant2['participantObjectId'] = 10003
participant2['role'] = 'REQ-PARTICIPANT'
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
app['_FLAGS'] = 'ignoreConflicts'
app['_PARTICIPANTS'] = [ participant1, participant2 ]

print
print "--Create--"
app = server.zogi.putObject(app)
pprint.pprint(app)

print
print "--Set Status--"
status = { }
status['comment'] = 'My very vert very very very very very very very very very very long comment'
status['objectId'] = app['objectId']
status['rsvp'] = 1
status['status'] = 'TENTATIVE'
status['entityName'] = 'ParticipantStatus'
pprint.pprint(server.zogi.putObject(status))

print
print "--Update Appointment--"
app = server.zogi.getObjectById(app['objectId'], 65535)
app['location'] = 'Whedonia'
app['_FLAGS'] = 'ignoreConflicts'
app = server.zogi.putObject(app)
if ((app['_PARTICIPANTS'][0]['status'] == 'TENTATIVE') and 
    (app['_PARTICIPANTS'][1]['status'] == 'NEEDS-ACTION')):
  print "OK!"
else:
  exit(1)

print
print "--Update appointment participants--"
participant1 = {}
participant1['participantObjectId'] = 10102
app['_PARTICIPANTS'] = [ participant1, participant2 ]
app['_FLAGS'] = 'ignoreConflicts'
app = server.zogi.putObject(app)
if ((app['_PARTICIPANTS'][0]['status'] == 'TENTATIVE') and 
    (app['_PARTICIPANTS'][1]['status'] == 'NEEDS-ACTION')):
  print "OK!"
else:
  exit(1)

