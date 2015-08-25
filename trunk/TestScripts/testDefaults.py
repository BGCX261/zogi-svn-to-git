#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
account = server.zogi.getLoginAccount(128)
defaults  = account['_DEFAULTS']
pprint.pprint(defaults)

print
defaults['appointmentReadAccessTeam'] = 0
defaults['appointmentWriteAccess'] = [9993]
defaults['timeZone'] = 'EST'
print 'Putting defaults object'
server.zogi.putObject(defaults)

print
account = server.zogi.getLoginAccount(128)
defaults  = account['_DEFAULTS']
pprint.pprint(defaults)

print
defaults['appointmentReadAccessTeam'] = 123456
defaults['appointmentWriteAccess'] = [10003, 10102]
defaults['timeZone'] = 'EST'
print 'Putting defaults object'
server.zogi.putObject(defaults)

print
account = server.zogi.getLoginAccount(128)
defaults  = account['_DEFAULTS']
server.zogi.putObject(defaults)
pprint.pprint(defaults)
