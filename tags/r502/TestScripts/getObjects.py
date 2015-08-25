#!/usr/bin/env python
import xmlrpclib, pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
pprint.pprint(server.zogi.getObjectsById([500040,19100, 27160, 10160], 65535))
