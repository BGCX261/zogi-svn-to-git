#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
pprint.pprint(server.zogi.getObjectById(496000, 65535))
