#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
criteria = { }
criteria['conjunction'] = 'AND'
criteria['name'] = 'Vendor%'
criteria['kind'] = ''
pprint.pprint(server.zogi.searchForObjects('Project', criteria, 4096))
