#!/usr/bin/env python
import xmlrpclib, pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
objects = [ 9161230 ]
result = server.zogi.getObjectsById(objects, 65535)
pprint.pprint(result)
