<?PHP

  require_once("zogi.php");

  if (isset($_POST["username"]))
  {
    $ogo = new OpenGroupwareServer(
                 "tor", 
                 $_POST["username"], 
                 $_POST["password"]);
    $accountId = @$ogo->getLoginAccountId();
    if ($accountId == null)
    {
      print 'Cannot connect to groupware using provided credentials';
      die(0);
    }
    print 'Retrieving enterprise...<br/>';
    $enterprise = $ogo->getObject(3049570, 32767);
    printf('Name: %s<br/>', $enterprise['name']);

    /* Change the division, this demonstrates using getSubkeyReference 
       A reference to the dictionary (keyed array) in _COMPANYVALUES
       with an "attribute" equal to "division" is returned.  Then its
       other components can be modified. */
    $cv = &$ogo->getSubkeyReference($enterprise, '_COMPANYVALUES', 'attribute', 'division');
    printf('Division: %s<br/>', $cv['value']);
    $cv['value'] = 'Test';
    $enterprise = $ogo->putObject($enterprise);
    $cv = &$ogo->getSubkeyReference($enterprise, '_COMPANYVALUES', 'attribute', 'division');
    printf('Division: %s<br/>', $cv['value']);
    $cv['value'] = 'MVP';
    $enterprise = $ogo->putObject($enterprise);
    $cv = &$ogo->getSubkeyReference($enterprise, '_COMPANYVALUES', 'attribute', 'division');
    printf('Division: %s<br/>', $cv['value']);

    /* Display the city from the ship address */
    $ship = &$ogo->getSubkeyReference($enterprise, '_ADDRESSES', 'type', 'ship');
    printf('City: %s<br/>', $ship['city']);
  } else
     {
       print '<FORM METHOD="POST" ACTION="zogiEnt.php">';
       print '</U>Provide username and password</U><BR/>';
       print 'Username: <INPUT SIZE=10 NAME="username"/><BR/>';
       print 'Password: <INPUT SIZE=10 NAME="password"/><BR/>';
       print '<INPUT TYPE="SUBMIT" VALUE="Login"/>';
       print '</FORM>';
     }

?>
