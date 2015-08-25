#!/usr/bin/env python
import xmlrpclib,pprint
server = xmlrpclib.Server('http://adam:fred123@localhost/zidestore/so/adam/')
#note = { } 
#note['appointmentObjectId'] = ''
#note['content'] = 'lshdfjklhskjhkjhklj\nasgjklhdsgsfsfasfsdf\nsdfhg;slkdfgsdghll'
#note['objectId'] = 11155601
#note['projectObjectId'] = 11080461
#note['title'] = 'Cisco 2500' 
project = { }
#project['_NOTES'] = [ note ]
project['comment'] = 'Deploy (and subsequently convert) internal network from IPv4 to IPv6\n\nWe have a SixXS <http://www.sixxs.net/tools/grh/ula/> registered internal IPv6 subnet of fdb5:60da:9b8a::/48  \n\nNote that IPv6 subnets *ALWAYS* have a netmask of /64 so we have 65,535 subnets available each with a potential 65,535 hosts.  Hah!'
#project['endDate'] = '2008-02-24 19:00:00'
project['entityName'] = 'Project'
project['name'] = 'CIS: IPv6 Deployment'
project['number'] = 'P11080461'
project['objectId'] = 11080461
project['placeHolder'] = 0
#project['startDate'] = '2028-12-30 19:00:00'
pprint.pprint(server.zogi.putObject(project))
