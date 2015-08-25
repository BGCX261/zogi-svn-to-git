#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
status = { }
#status['comment'] = 'This is my very pretty comment.'
status['objectId'] = 10700730
#status['rsvp'] = 0
#status['status'] = 'ACCEPTED'
status['entityName'] = 'ParticipantStatus'
pprint.pprint(server.zogi.putObject(status))

