#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria = { }
criteria['startDate'] = '2006-12-31'
criteria['endDate'] = '2008-01-01'
pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 65535))

