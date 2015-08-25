#!/usr/bin/env python
import xmlrpclib, pprint
server = xmlrpclib.Server('http://adam:*****@localhost/zidestore/so/adam/')
objects = [ 10000,
            26850,
            10100,
            125630,
            116340,
            450000,
            202350,
            8824310,
            25380,
            1149490,
            1128460,
            4946320 
          ] 
result = server.zogi.getObjectsById(objects, 65535)
pprint.pprint(result)
