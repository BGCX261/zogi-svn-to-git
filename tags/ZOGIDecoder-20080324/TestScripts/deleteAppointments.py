#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
criteria = { }
criteria['startDate'] = '2006-12-31'
criteria['endDate'] = '2008-01-01'
result = server.zogi.searchForObjects('Appointment', criteria, 0)
for appointment in result:
  server.zogi.deleteObject(appointment)
  print "Appointment %d deleted.\n" % appointment['objectId']
