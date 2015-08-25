#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria = { }
criteria['conjunction'] = 'AND'
criteria['category'] = 'Room'
criteria['notificationTime'] = 720
pprint.pprint(server.zogi.searchForObjects('Resource', criteria, 65535))

