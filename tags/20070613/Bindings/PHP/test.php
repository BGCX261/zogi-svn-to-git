<?PHP
 
 /*  
   License: LGPL
   Copyright 2007, Whitemice Consulting
   Adam Tauno Williams
   awilliam@whitemiceconsulting.com
 */

  require_once("zogi.php");
  $ogo = new OpenGroupwareServer("localhost", "awilliam", "fred");
  echo "Account Object Id is:" . $ogo->getLoginAccountId(). "<BR/>";

  /*
  echo "<BR/>Get Login Account<BR/>";
  $result = $ogo->getLoginAccount(65535);
  print_r($result);

  echo "<BR/>Get Object<BR/>";
  $result = $ogo->getObject(491010, 65535);
  print_r($result);

  echo "<BR/>Get Objects<BR/>";
  $result = $ogo->getObjects(array(10160, 491010), 65535);
  print_r($result);

  echo "<BR/>Create Task<BR/>";
  $task = array();
  $task['entityName'] = 'Task';
  $task['name'] = 'New ZOGI/PHP Task 5';
  $task['executantObjectId'] = 10160;
  $task['objectId'] = '0';  
  $task['keywords'] = 'ZOGI';
  $task['comment'] = 'COMMENT COMMENT COMMENT';
  $task['priority'] = 2;
  $task['startDate'] = '2006-12-31';
  $task['endDate'] = '2007-01-25';
  $task['sensitivity'] = 2;
  $task['totalWork'] = 75;
  $task['percentComplete'] = 40;
  $task['notify'] = 1;
  $task['kilometers'] = 34;
  $task['accountingInfo'] = 'Accounting Info';
  $task['actualWork'] = 23;
  $task = $ogo->putObject($task);
  print_r($task);

  echo "<BR/>Update Task<BR/>";
  $task['name'] = 'Updated ZOGI/PHP Task 5';
  $task = $ogo->putObject($task);
  print_r($task);

  echo "<BR/>Accept a task<BR/>";
  $notation = array();
  $notation['entityName'] = 'taskNotation';
  $notation['taskObjectId'] = $task['objectId'];
  $notation['comment'] = 'Perform accept';
  $notation['action'] = 'accept';
  print_r($ogo->putObject($notation));

  echo "<BR/>Comment a task<BR/>";
  $notation = array();
  $notation['entityName'] = 'taskNotation';
  $notation['taskObjectId'] = $task['objectId'];
  $notation['comment'] = 'Comment';
  $notation['action'] = 'comment';
  print_r($ogo->putObject($notation));

  echo "<BR/>Done a task<BR/>";
  $notation = array();
  $notation['entityName'] = 'taskNotation';
  $notation['taskObjectId'] = $task['objectId'];
  $notation['comment'] = 'It is done';
  $notation['action'] = 'done';
  print_r($ogo->putObject($notation));

  echo "<BR/>Archive a task<BR/>";
  $notation = array();
  $notation['entityName'] = 'taskNotation';
  $notation['taskObjectId'] = $task['objectId'];
  $notation['comment'] = 'Archive';
  $notation['action'] = 'archive';
  print_r($ogo->putObject($notation));

  echo "<BR/>Get appointments<BR/>";
  $criteria = array();
  $criteria['startDate'] = '2006-01-01';
  $criteria['endDate'] = '2007-12-31';
  print_r($ogo->searchForObjects('Appointment', $criteria, 65535));

  echo "<BR/>Get to-do list<BR/>";
  print_r($ogo->searchForObjects('Task', 'todo' ,65535));
  */


?>
