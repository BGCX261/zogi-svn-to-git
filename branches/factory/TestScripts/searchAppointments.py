#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
#criteria = { }
#criteria['startDate'] = '2007-09-01 00:00'
#criteria['endDate'] = '2007-09-31 23:59'
#pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 4))
#print
#criteria['appointmentType'] = 'home' 
#pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 4))
#print
#criteria['appointmentType'] = [ 'meeting', 'outward' ]
#pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 4))
print
criteria = { }
criteria['participants'] = [ 10100 ]
criteria['startDate'] = '2007-12-10 00:00'
criteria['endDate'] = '2007-12-19 00:00'
pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 4))
#print
#criteria['participants'] = '10201451'
#criteria['appointmentType'] = 'tradeshow'
#flags = { 'limit' : 150, 'filter' : '(ownerObjectId = 10100)' }
#pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 4, flags))
#print
#criteria = { }
#criteria['startDate'] = '2006-01-01 00:00'
#criteria['endDate'] = '2007-12-31 23:59'
#flags = { }
#for app in server.zogi.searchForObjects('Appointment', criteria, 4, flags):
##  print '%d: %s - %s to %s' % (app['objectId'], app['title'], app['start'], app['end'])
