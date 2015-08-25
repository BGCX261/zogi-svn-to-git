#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://adam:Kador23@localhost/zidestore/so/adam/')
#pprint.pprint(server.zogi.searchForObjects('Team', 'all', 128))
#pprint.pprint(server.zogi.searchForObjects('Team', 'all', 256))
#pprint.pprint(server.zogi.searchForObjects('Team', 'mine', 128))
pprint.pprint(server.zogi.searchForObjects('Team', 'mine', 0))

