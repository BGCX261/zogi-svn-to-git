<?PHP

 /* 
   License: LGPL
   Copyright 2007, Whitemice Consulting
   Adam Tauno Williams
   awilliam@whitemiceconsulting.com

   This is the only file your application needs, other PHP files in this 
   directory are tests/demonstrations.

   Requires PEAR XML_RPC 1.5.1
 */

  require_once('XML/RPC.php');

  class OpenGroupwareServer {
    var $client;
    var $account;

    function OpenGroupwareServer($_hostname, $_username, $_secret, $_port = 80)
    {
      $uri = "/zidestore/so/" . trim($_username) . "/";
      $this->client = new XML_RPC_Client($uri, $_hostname, $_port);
      $this->client->setCredentials($_username, $_secret);
      $this->account = $this->getLoginAccount(0);
    } /* End method OpenGroupwareServer */
  
    /****************** PUBLIC METHODS *******************/

    function getLoginAccount($_detail)
    {
     $params = array(new XML_RPC_Value($_detail, 'int'));
     $message = new XML_RPC_Message('zogi.getLoginAccount', $params);
     $response = $this->client->send($message);
     return $this->unwrap($response->value());
    }

	/* Returns the objectId of the login account;  this can be used
       to check login status;  if it returns 0 then you have not
       yet successfully connected to the service */
    function getLoginAccountId()
    {
      if (is_array($this->account))
        return $this->account['objectId'];
      return 0;
    }

    /* Get object data for one specific object from the server */
    function getObject($_objectId, $_detail)
    {
     $params = array(new XML_RPC_Value($_objectId, 'int'),
                     new XML_RPC_Value($_detail, 'int'));
     $message = new XML_RPC_Message('zogi.getObjectById', $params);
     $response = $this->client->send($message);
     return $this->unwrap($response->value());
    } /* End method getObject */

    /* Get object data from the server for a list of objects */
    function getObjects($_objectIds, $_detail)
    {
      $ids = array();
      foreach($_objectIds as $objectId)
        array_push($ids, new XML_RPC_Value($objectId, 'int'));
      $params = array(new XML_RPC_Value($ids, 'array'),
                       new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.getObjectsById', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    } /* End method getObjects */

    /* Copy an object to the server */
    function putObject($_object, $_flags = '')
    {
      $params = array($this->wrap($_object));
      $message = new XML_RPC_Message('zogi.putObject', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* 
       Delete an object from the server 
       Returns a 0 on failure or a 1 on success
     */
    function deleteObject($_object, $_flags = '')
    {
	  if(is_array($_object))
		$params = array(new XML_RPC_Value($_object['objectId'], 'int'));
       else
         $params = array(new XML_RPC_Value($_object, 'int'));
      $message = new XML_RPC_Message('zogi.deleteObject', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* Search for objects */
	function searchForObjects($_entityName, $_criteria, $_detail = 0)
    {
      $params = array(new XML_RPC_Value($_entityName, 'string'),
                       $this->wrap($_criteria),
                       new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.searchForObjects', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* Get the list of favorite objects */
    function getFavoritesByType($_entityName, $_detail = 0)
    {
      $params = array(new XML_RPC_Value($_entityName, 'string'),
                       new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.getFavoritesByType', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* Mark objects as favorites*/
    function flagFavorites($_favIds)
    {
      if (is_array($_favIds))
        $params = array(new XML_RPC_Value($_favIds, 'array'));
      else 
        $params = array(new XML_RPC_Value($_favIds, 'string'));
      $message = new XML_RPC_Message('zogi.flagFavorites', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* Remove favorite status from objects */
    function unflagFavorites($_favIds)
    {
      if (is_array($_favIds))
        $params = array(new XML_RPC_Value($_favIds, 'array'));
      else  
        $params = array(new XML_RPC_Value($_favIds, 'string'));
      $message = new XML_RPC_Message('zogi.unflagFavorites', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    }

    /* Get a subkey reference 
       WARNING: PHP is a very stupid and ugly language,  you need
                to indicate pass-by-reference for both the function
                declaration AND on the receiver.  Ick!
       http://us.php.net/manual/en/language.references.return.php */
    function &getSubkeyReference(&$_entity, $_key, $_attribute, $_value)
    {
      if (is_array($_entity[$_key]))
      {
        for($i = 0; $i < count($_entity[$_key]); $i++)
        {
          if (isset($_entity[$_key][$i][$_attribute]))
            if($_entity[$_key][$i][$_attribute] == $_value)
              return $_entity[$_key][$i];
        }
      }
      return null;
    }

    /****************** PRIVATE METHODS *******************/

    /* PRIVATE METHOD */
    function unwrap($value) 
    {
      switch ($value->kindOf())
      {
        case 'scalar':
          switch ($value->scalartyp()) 
          {
            case 'dateTime.iso8601':
              $result =  XML_RPC_iso8601_decode($value->scalarval());
              $result = date('Y-m-d H:i', $result);
             break;
            case 'boolean':
              $result = $value->scalarval();
             break;
            case 'int':
              $result = $value->scalarval();
             break;
            default:
              $result = $value->scalarval();
             break;
          }
         break;
        case'array':
          $result_size = $value->arraysize();
          $result = array();
          for($i = 0; $i < $result_size; $i++) 
          {
            $result[]=$this->unwrap($value->arraymem($i));
          }
         break;
        case 'struct':
          $value->structreset();
          $result = array();
          while(list($key,$val)=$value->structeach()) 
          {
            $result[$key] = $this->unwrap($val);
          }
         break;
       }
      return $result;
    } /* End method: unwrap */

    /* PRIVATE METHOD */
    function wrap($_value) 
    {
      switch(gettype($_value)) 
      {
        case 'boolean':
          $_value = new XML_RPC_value($_value, 'boolean');
         break;
        case 'integer':
          $_value = new XML_RPC_value($_value, 'int');
         break;
        case 'double':
          $_value = new XML_RPC_value($_value, 'double');
         break;
        case 'string':
          $_value = new XML_RPC_value($_value, 'string');
         break;
        case 'array':
          $_a = array();
          reset($_value);
          if (key($_value) == '0') 
          { //array
            $_a_type = 'array';
            foreach ($_value as $_v)
               array_push($_a, $this->wrap($_v));
          } else 
            {  //struct
               $_a_type = 'struct';
               foreach ($_value as $_k => $_v)
                 $_a[$_k] = $this->wrap($_v);
            }
          $_value = new XML_RPC_value($_a, $_a_type);
         break;
        case 'object':
          switch(get_class($_value)) 
          {
            case 'OGoRPCNull':
            case 'ogorpcnull':
             break;
            default:
              /// This is some other type of object
              /// NOT SUPPORTED
             break;
          } /* End key value is an object switching */
         break;
        case 'resource':
          /// NOT SUPPORTED
         break;
        case 'NULL':
          /// NOT SUPPORTED
         break;
       } /* End key value type switching */
      return $_value;
     } /* End method wrap */
  } /* End class */
?>
