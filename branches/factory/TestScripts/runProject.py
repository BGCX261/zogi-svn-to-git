#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')

notation1 = {}
notation1['title'] = 'Title Of First Note'
notation1['content'] = 'Content of first appointment notation'
notation1['entityName'] = 'note'
notation1['objectId'] = 0

link = { }
link['objectId'] = '0';
link['targetObjectId'] = 10160
link['type'] = 'generic'
link['label'] = 'Another Label'

property = {}
property['propertyName'] = '{http://www.whitemiceconsulting.com/properties/ext-attr}myIntAttribute'
property['value'] = 7

print '---- project-----'
project = { }
project['entityName'] = 'Project'
project['name'] = 'New ZOGI Project IIiI'
project['comment'] = 'This is a project created by ZOGI'
project['_NOTES'] = [ notation1 ]
project['_OBJECTLINKS'] = [ link ]
project['_PROPERTIES'] = [ property ]
project = server.zogi.putObject(project)
pprint.pprint(project)
print

print '----Update project-----'
project['name'] = 'Updated project name 3'
project['comment'] = 'Update project comment'
project = server.zogi.putObject(project)
project['_PROPERTIES'] = [ ]
pprint.pprint(project)
print

print '----Delete project-----'
print server.zogi.deleteObject(project);
print

print '----Get deleted project---'
print server.zogi.getObjectById(project['objectId'])

