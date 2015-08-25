#!/usr/bin/env python
import xmlrpclib
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print server.zogi.getAppointmentsById(28310, 65535)
