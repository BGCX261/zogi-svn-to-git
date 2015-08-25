#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print "--Comment--"
notation = { }
notation['entityName'] = 'taskNotation'
notation['comment'] = 'THIS IS A COMMENT'
notation['action'] = 'comment'
notation['taskObjectId'] = 481160;
notation['objectId'] = 0;
pprint.pprint(server.zogi.putObject(notation))
