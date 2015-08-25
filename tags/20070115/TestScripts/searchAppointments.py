#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria = { }
criteria['startDate'] = '2006-01-01'
criteria['endDate'] = '2006-12-31'
pprint.pprint(server.zogi.searchForObjects('Appointment', criteria, 65535))

