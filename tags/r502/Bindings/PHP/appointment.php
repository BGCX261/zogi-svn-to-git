<?PHP
 
 /*  
   License: LGPL
   Copyright 2007, Whitemice Consulting
   Adam Tauno Williams
   awilliam@whitemiceconsulting.com
   
   This file is a test/demonstation of all the actions that can be performed
   on an appointment.
 */

  require_once("zogi.php");
  $ogo = new OpenGroupwareServer("localhost", "awilliam", "fred");
  echo "Account Object Id is:" . $ogo->getLoginAccountId(). "<BR/>";

  $participant1 = array();
  $participant1['participantObjectId'] = 10160;
  $participant1['role'] = 'CHAIR';
  $participant1['comment'] = 'This dude rocks';

  $participant2 = array();
  $participant2['participantObjectId'] = 10003;
  $participant2['role'] = 'REQ-PARTICIPANT';

  # Setup note
  $notation1 = array();
  $notation1['title'] = 'Title Of First Note';
  $notation1['content'] = 'Content of first appointment notation';
  $notation1['entityName'] = 'note';
  $notation1['objectId'] = 0;

  $notation2 = array();
  $notation2['title'] = 'Title Of Second Note';
  $notation2['content'] = 'Content of second appointment notation';
  $notation2['entityName'] = 'note';
  $notation2['objectId'] = 0;

  $app = array();
  $app['entityName'] = 'Appointment';
  $app['objectId'] = '0';
  $app['keywords'] = 'ZOGI';
  $app['comment'] = 'COMMENT COMMENT COMMENT';
  $app['start'] = '2007-02-18 13:00';
  $app['end'] = '2007-02-18 15:00';
  $app['title'] = 'My New 2007 Appointment';
  $app['location'] = 'Sardinia';
  $app['_FLAGS'] = 'ignoreConflicts';
  $app['_NOTES'] = array($notation1);
  $app['_PARTICIPANTS'] = array($participant1, $participant2);

  print "<BR/>--Create--<BR/>";
  $app = $ogo->putObject($app);
  print_r($app);

  print "<BR/>--Put Note ---<BR/>";
  /* This adds a second note, we preserve the first note */
  $app['_NOTES'] = array($app['_NOTES'][0], $notation2);
  $app['_FLAGS'] = 'ignoreConflicts';
  $app = $ogo->putObject($app);
  print_r($app['_NOTES']);

  print "<BR/>--Update, updating note--<BR/>";
  print "objectId: " . $app['objectId'];
  $app['title'] = 'Modified Appointment';
  $app['_FLAGS'] = 'ignoreConflicts';
  /* We are dropping one of the participants */
  $app['_PARTICIPANTS'] = array($participant2);
  /* We are changing the content of one of the notes */
  $app['_NOTES'][0]['title'] = 'Updated note title';
  $app['_NOTES'][0]['content'] = 'Updated content of note';
  $app = $ogo->putObject($app);
  print_r($app['_NOTES']);

  print "<BR/>--Update, erasing notes--<BR/>";
  /* We are dropping the second note */
  $app['_NOTES'] = array($app['_NOTES'][0]);
  $app['_FLAGS'] = 'ignoreConflicts';
  $app = $ogo->putObject($app);
  print_r($app['_NOTES']);

  print "<BR/>--Update, adding properties--<BR/>";
  /* USE YOUR OWN $%*@&(*$) NAMESPACE FOR CUSTOM PROPERTIES */
  $property1 = array();
  $property1['propertyName'] = '{http://www.example.com/properties/ext-attr}myIntAttribute';
  $property1['value'] = 7;
  
  $property2 = array();
  $property2['propertyName'] = '{http://www.example.com/properties/ext-attr}myStringAttribute';
  $property2['value'] = 'Hi there';
  /* We are adding two properties */
  $app['_PROPERTIES'] = array($property1, $property2);
  $app['_FLAGS'] = 'ignoreConflicts';
  $app = $ogo->putObject($app);
  print_r($app['_PROPERTIES']);

  print "<BR/>--Update, changing properties--<BR/>";
  $property1 = array();
  $property1['propertyName'] = '{http://www.example.com/properties/ext-attr}myIntAttribute';
  $property1['value'] = 4;
  $property2 = array();
  $property2['namespace'] = 'http://www.example.com/properties/ext-attr';
  $property2['attribute'] = 'myStringAttribute';
  $property2['value'] = 'Ho there';
  $app['_PROPERTIES'] = array($property1, $property2);
  $app['_FLAGS'] = 'ignoreConflicts';
  $app = $ogo->putObject($app);
  print_r($app['_PROPERTIES']);

  print "<BR/>--Update, deleting property--<BR/>";
  /* We are dropping the first property */
  $app['_PROPERTIES'] = array($app['_PROPERTIES'][1]);
  $app['_FLAGS'] = 'ignoreConflicts';
  $app = $ogo->putObject($app);
  print_r($app['_PROPERTIES']);

  print "<BR/>--Get--<BR/>";
  $app = $ogo->getObject($app['objectId'], 65535);
  print_r($app);

  print "<BR/>--Delete--<BR/>";
  #app = server.zogi.deleteObject(app, ['deleteCycle'])
  print_r($ogo->deleteObject($app['objectId']))

?>
