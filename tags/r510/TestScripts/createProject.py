#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
print '---- project-----'
project = { }
project['entityName'] = 'Project'
project['name'] = 'New ZOGI Project IIiI'
project['comment'] = 'This is a project created by ZOGI'
project = server.zogi.putObject(project)
pprint.pprint(project)
print

print '----Update project-----'
project['name'] = 'Updated project name 3'
project['comment'] = 'Update project comment'
project = server.zogi.putObject(project)
pprint.pprint(project)
print

print '----Delete project-----'
print server.zogi.deleteObject(project);
print

print '----Get deleted project---'
print server.zogi.getObjectById(project['objectId'])

