#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
contacts = server.zogi.getFavoritesByType("Contact", 0)
for contact in contacts:
  print '%d: %s, %s' % (contact['objectId'], contact['lastName'], contact['firstName'])
