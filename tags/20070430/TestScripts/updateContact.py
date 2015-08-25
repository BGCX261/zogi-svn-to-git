#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
contact = server.zogi.getObjectById(10160, 65535)
contact['fileAs'] = 'Williams, Adam'
contact = server.zogi.putObject(contact)
pprint.pprint(contact)
