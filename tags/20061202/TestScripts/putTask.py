#!/usr/bin/env python
import xmlrpclib, time

server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
task = { }
task['entityName'] = 'Task'
task['name'] = 'New ZOGI Task'
task['executantObjectId'] = 25850
task['objectId'] = '0'
task['keywords'] = 'ZOGI'
task['comment'] = 'COMMENT COMMENT COMMENT'
task['priority'] = 2
task['category'] = 'No Category'
task['projectObjectId'] = 29420
task['sensitivity'] = 2
task['totalWork'] = 75
task['parentTaskObjectId'] = 25850
task['percentComplete'] = 63
task['notify'] = 0
task['kilometers'] = 34
task['accountingInfo'] = 'Accounting Info'
task['actualWork'] = 23
task['associatedCompanies'] = 'Company A,Company B'
task['associatedContacts'] = 'Contact A,Contact B'
print "--Create--"
task = server.zogi.putObject(task)
print task
print "--Update--"
task['name'] = 'Updated ZOGI Task'
task['kilometers'] = 99
task = server.zogi.putObject(task)
print task
print "--Accept--"
print server.zogi.putTaskNotation(task['objectId'], "accept", "Perform accept");
print "--Comment--"
print server.zogi.putTaskNotation(task['objectId'], "comment", "THIS IS A COMMENT!!!");
print "--Done--"
print server.zogi.putTaskNotation(task['objectId'], "done", "Mark as done");
print "--Archive--"
print server.zogi.putTaskNotation(task['objectId'], "archive", "Archive this");
print "--Reactivate--"
print server.zogi.putTaskNotation(task['objectId'], "reactivate", "Reactivate this");
print "--Reject--"
print server.zogi.putTaskNotation(task['objectId'], "reject", "Reject this");
print "--Archive--"
print server.zogi.putTaskNotation(task['objectId'], "archive", "Archive this again");
print "--Get--"
print server.zogi.getObjectById(task['objectId'], 65535)
print "--GetVersion--"
print server.zogi.getObjectVersionsById(task['objectId'])

