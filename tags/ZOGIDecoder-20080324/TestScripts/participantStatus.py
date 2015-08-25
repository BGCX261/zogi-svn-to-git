#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
pprint.pprint(server.zogi.getObjectById(10621, 4))
status = { }
status['comment'] = 'My very vert very very very very very very very very very very long comment'
status['objectId'] = 10621
status['rsvp'] = 1
status['status'] = 'TENTATIVE'
status['entityName'] = 'ParticipantStatus'
pprint.pprint(server.zogi.putObject(status))
status['comment'] = 'My short comment'
status['status'] = 'accepted'
status['rsvp'] = 0
pprint.pprint(server.zogi.putObject(status))

