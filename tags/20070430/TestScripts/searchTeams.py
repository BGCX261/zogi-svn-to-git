#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
pprint.pprint(server.zogi.searchForObjects('Team', 'all', 0))

