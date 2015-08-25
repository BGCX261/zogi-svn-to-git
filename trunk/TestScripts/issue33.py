#!/usr/bin/env python
import xmlrpclib, time, sys

server =
xmlrpclib.Server('http://{USER}:{PASSWORD}@{HOST}/zidestore/so/{HOST}/'
app = { }
app['entityName'] = 'Appointment'
app['objectId'] = '0'
app['start'] = '2008-10-24 16:00'
app['end'] = '2008-10-24 17:00'
app['title'] = 'daylight savings test appointment'
app['_FLAGS'] = 'ignoreConflicts'
app['timeZone'] = 'MET'
app['cycleEndDate'] = '2008-10-28 00:00'
app['cycleType'] = 'RRULE:FREQ=DAILY;UNTIL=20081027'

