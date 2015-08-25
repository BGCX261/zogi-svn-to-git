#!/usr/bin/env python
import xmlrpclib, time, sys

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
project = { }
project['entityName'] = 'Project'
project['name'] = 'New ZOGI Project IIiI'
project['comment'] = 'This is a project created by ZOGI'
project = server.zogi.putObject(project)
print project

print

project['name'] = 'Updated project name 3'
project['comment'] = 'Update project comment'
project = server.zogi.putObject(project)
print project
