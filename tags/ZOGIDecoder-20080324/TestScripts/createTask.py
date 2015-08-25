#!/usr/bin/env python
import xmlrpclib, time, sys, pprint

server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
task = { }
task['entityName'] = 'Task'
task['name'] = 'New ZOGI Task 5'
task['executantObjectId'] = 10160
task['objectId'] = '0'
task['keywords'] = 'ZOGI'
task['comment'] = 'COMMENT COMMENT COMMENT'
task['priority'] = 2
#task['category'] = 'No Category'
#task['projectObjectId'] = 10890
task['startDate'] = '2006-12-31'
task['endDate'] = '2007-01-25'
task['sensitivity'] = 2
task['totalWork'] = 75
#task['parentTaskObjectId'] = 25850
task['percentComplete'] = 40
task['notify'] = 1
task['kilometers'] = 34
task['accountingInfo'] = 'Accounting Info'
task['actualWork'] = 23
#task['associatedCompanies'] = 'Company A,Company B'
#task['associatedContacts'] = 'Contact A,Contact B'
link = { }
link['objectId'] = '0';
link['targetObjectId'] = 10000
link['type'] = 'generic'
link['label'] = 'Object Link Label'
task['_OBJECTLINKS'] = [ link ];
print "--Create--"
task = server.zogi.putObject(task)
print task
print "--Update--"
print "objectId: %s" % task['objectId']
task['name'] = 'Updated ZOGI Task 5'
#link = { }
#link['objectId'] = '0';
#link['targetObjectId'] = 10520
#link['type'] = 'generic'
#link['label'] = 'Another Label'
#task['_OBJECTLINKS'] = [ link ]
task = server.zogi.putObject(task)
pprint.pprint(task)
print "--Accept--"
notation = {}
notation['entityName'] = 'taskNotation'
notation['taskObjectId'] = task['objectId']
notation['comment'] = 'Perform accept'
notation['action'] = 'accept'
print server.zogi.putObject(notation);
print "--Comment--"
notation['comment'] = 'THIS IS A COMMENT'
notation['action'] = 'comment'
print server.zogi.putObject(notation);
print "--Done--"
notation['comment'] = 'Mark as done'
notation['action'] = 'done'
print server.zogi.putObject(notation);
print "--Archive--"
notation['comment'] = 'Archive this'
notation['action'] = 'archive'
print server.zogi.putObject(notation);
print "--Reactivate--"
notation['comment'] = 'Reactivate this'
notation['action'] = 'reactivate'
print server.zogi.putObject(notation);
print "--Reject--"
notation['comment'] = 'Reject this'
notation['action'] = 'reject'
print server.zogi.putObject(notation);
#print "--Archive--"
#notation['comment'] = 'Archive this again'
#notation['action'] = 'archive'
print server.zogi.putObject(notation);
print "--Get--"
pprint.pprint(server.zogi.getObjectById(task['objectId'], 65535))
print "--GetVersion--"
print server.zogi.getObjectVersionsById(task['objectId'])

