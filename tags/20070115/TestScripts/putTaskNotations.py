#!/usr/bin/env python
import xmlrpclib
taskId = 10930
server = xmlrpclib.Server('http://awilliam:fred@localhost/zidestore/so/awilliam/')
#print server.zogi.putTaskNotation(taskId, "accept", "");
#print server.zogi.putTaskNotation(taskId, "comment", "THIS IS A COMMENT!!!");
#print server.zogi.putTaskNotation(taskId, "done", "");
#print server.zogi.putTaskNotation(taskId, "archive", "");
#print server.zogi.putTaskNotation(taskId, "reactivate", "");
#print server.zogi.putTaskNotation(taskId, "reject", "");
print server.zogi.putTaskNotation(taskId, "archive", "");
#print "-----"
#print server.zogi.getTasksById(taskId, 65535)
