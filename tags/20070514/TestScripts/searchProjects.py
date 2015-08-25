#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
criteria = { }
criteria['conjunction'] = 'AND'
criteria['name'] = 'project'
criteria['kind'] = ''
pprint.pprint(server.zogi.searchForObjects('Project', criteria, 65535))
