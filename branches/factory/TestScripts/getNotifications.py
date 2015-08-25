#!/usr/bin/env python
import xmlrpclib, time, pprint

server = xmlrpclib.Server('http://ogo:fred123@localhost/zidestore/so/ogo/')
pprint.pprint(server.zogi.getNotifications('2007-09-14 06:43', '2007-12-24 16:44'))

