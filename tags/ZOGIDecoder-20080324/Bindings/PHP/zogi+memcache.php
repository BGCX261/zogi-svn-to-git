<?PHP

 /* 
   License: LGPL http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
   Copyright 2007, Whitemice Consulting
   Adam Tauno Williams
   awilliam@whitemiceconsulting.com

   This is the only file your application needs, other PHP files in this 
   directory are tests/demonstrations.

   Requires PEAR XML_RPC 1.5.1
   Optionally requires the Memcache module
 */

  require_once('XML/RPC.php');

  class OpenGroupwareServer {
    var $client;
    var $account;
    var $cache;
    var $hit_count;
    var $check_count;
    var $stamp;
    var $rpc_time;

    function OpenGroupwareServer(
      $_hostname, 
      $_username,
      $_secret, 
      $_port = 80,
      $_config = array())
    {
      $this->stamp = microtime(true);
      $this->hit_count = $this->check_count = 0;
      $rpc_time = 0.0;
      $uri = "/zidestore/so/" . trim($_username) . "/";
      $this->client = new XML_RPC_Client($uri, $_hostname, $_port);
      $this->client->setCredentials($_username, $_secret);
      $this->client->setDebug(0);
      if (isset($_config['cacheHost']))
      {
        $this->cache = new Memcache();
        $this->cache->connect($_config['cacheHost'], $_config['cachePort']);
      } else
          $this->cache = null;
      $this->account = $this->getLoginAccount(0);
    } /* end method OpenGroupwareServer */

    function __destruct()
    {
       syslog(LOG_DEBUG, sprintf("zOGI object disposed after %f seconds",
                           (microtime(true) - $this->stamp)));
       syslog(LOG_DEBUG, sprintf("zOGI RPC total time was %f seconds",
                           $this->rpc_time));
       if ($this->check_count > 0)
         syslog(LOG_INFO, 
           sprintf("zOGI cache rate was %d%% (%d of %d)",
             ((intval($this->hit_count) / intval($this->check_count)) * 100),
             $this->hit_count,
             $this->check_count));
    } /* end __destruct() */
  
    /****************** PUBLIC METHODS *******************/

    /* Returns the account of the current user 
       http://code.google.com/p/zogi/wiki/getLoginAccount */
    function getLoginAccount($_detail)
    {
      $params = array(new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.getLoginAccount', $params);
      $start = microtime(true);
      $response = $this->client->send($message);
      $result = $this->unwrap($response->value());
      $this->rpc_time += (microtime(true) - $start);
      return $result;
    } /* end getLoginAccount */

    /* Returns the objectId of the login account;  this can be used
       to check login status;  if it returns 0 then you have not
       yet successfully connected to the service  */
    function getLoginAccountId()
    {
      if (is_array($this->account))
        return $this->account['objectId'];
      return 0;
    } /* end getLoginAccountId */

    /* Get object data for one specific object from the server 
       http://code.google.com/p/zogi/wiki/getObjectById */
    function getObject($_objectId, $_detail, $_useCache = true)
    {
      $start = microtime(true);
      if ($_useCache)
      {
        if ($this->cache)
        {
          $result = $this->_getFromCache($_objectId, $_detail);
          if ($result) 
            return $result;
        }
      }
      $params = array(new XML_RPC_Value($_objectId, 'int'),
                      new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.getObjectById', $params);
      $rpc_start = microtime(true);
      $response = $this->client->send($message);
      syslog(LOG_DEBUG, sprintf('zOGI Get Object RPC returned in %f seconds',
                                 (microtime(true) - $rpc_start)));
      $this->rpc_time += (microtime(true) - $rpc_start);
      $result = $this->unwrap($response->value());
      if($_useCache)
        $this->_putToCache($result, $_detail);
      syslog(LOG_DEBUG, sprintf('zOGI Get Object completed in %f seconds',
                                 (microtime(true) - $start)));
      return $result;
    } /* end getObject */

    /* Get object data from the server for a list of objects 
       http://code.google.com/p/zogi/wiki/getObjectsById */
    function getObjects($_objectIds, $_detail, $_useCache = true)
    {
      syslog(LOG_DEBUG, sprintf('zOGI Get Objects request for %d objects', 
               count($_objectIds)));
      $ids = array();
      $cached = array();
      if ($_useCache)
      {
        if ($this->cache)
        {
          foreach($_objectIds as $objectId)
          {
            $object = $this->_getFromCache($objectId, $_detail);
            if (is_array($object))
            {
              array_push($cached, $object);
            } else
              {
                array_push($ids, new XML_RPC_Value($objectId, 'int'));
              }
          }
        } else 
          {
            syslog(LOG_ERR, 'zOGI Get Objects intended to use cache, but cache not initialized');
            foreach($_objectIds as $objectId)
              array_push($ids, new XML_RPC_Value($objectId, 'int'));
          }
      } else
        {
          foreach($_objectIds as $objectId)
            array_push($ids, new XML_RPC_Value($objectId, 'int'));
        }
      if (count($ids) > 0)
      {
        $params = array(new XML_RPC_Value($ids, 'array'),
                         new XML_RPC_Value($_detail, 'int'));
        syslog(LOG_DEBUG, sprintf('zOGI Get Objects requesting %d objects', count($ids)));
        $message = new XML_RPC_Message('zogi.getObjectsById', $params);
        $start = microtime(true);
        $response = $this->client->send($message);
        syslog(LOG_DEBUG, sprintf('zOGI Get Objects RPC returned in %f seconds',
                                   (microtime(true) - $start)));
        $this->rpc_time += (microtime(true) - $start);
        $result = $this->unwrap($response->value());
        if($_useCache)
        {
          if ($this->cache)
            foreach($result as $object)
              $this->_putToCache($object, $_detail);
        }
      } else $result = array();
      foreach($cached as $object)
        array_push($result, $object);
      return $result;
    } /* end getObjects */

    /* Copy an object to the server 
       http://code.google.com/p/zogi/wiki/putObject */
    function putObject($_object, $_flags = '')
    {
      /* Need to ripple from unmodified object in case any references,
         such as an association with an enterprise, was dropped.  This
         will purge the cache of objects we know state relationships to 
         the object being updated. */ 
      if ($this->cache)
        $this->_rippleCache($_object, 'pre-putObject');
      $params = array($this->wrap($_object));
      $message = new XML_RPC_Message('zogi.putObject', $params);
      $start = microtime(true);
      $response = $this->client->send($message);
      syslog(LOG_DEBUG, sprintf('zOGI Put Object RPC returned in %f seconds',
                                 (microtime(true) - $start)));
      $this->rpc_time += (microtime(true) - $start);
      $result = $this->unwrap($response->value());
      if ($this->cache)
      {
        $this->_putToCache($result, 65535);
        /* Need to ripple from modified object in case any references,
           such as an association with an enterprise, was added.  This
           will purge the cache of objects which might not know they
           are now related to this object. */
        $this->_rippleCache($result, 'post-putObject');
      }
      return $result;
    } /* end putObject */

    /* 
       Delete an object from the server 
       Returns a 0 on failure or a 1 on success
       http://code.google.com/p/zogi/wiki/deleteObject 
     */
    function deleteObject($_object, $_flags = '')
    {
      if ($this->cache)
        $this->_rippleCache($result, 'pre-delete');
      if(is_array($_object))
        $params = array(new XML_RPC_Value($_object['objectId'], 'int'));
      else
        $params = array(new XML_RPC_Value($_object, 'int'));
      $message = new XML_RPC_Message('zogi.deleteObject', $params);
      if ($this->cache)
        $this->_removeFromCache($_object);
      $start = microtime(true);
      $response = $this->client->send($message);
      syslog(LOG_DEBUG, sprintf('zOGI Delete RPC returned in %f seconds',
                                (microtime(true) - $start)));
      $this->rpc_time += (microtime(true) - $start);
      return $this->unwrap($response->value());
    } /* end deleteObject */

    /* Search for objects 
       http://code.google.com/p/zogi/wiki/searchForObjects */
	  function searchForObjects($_entityName, 
                                  $_criteria, 
                                  $_detail = 0, 
                                  $_flags = array())
    {
      $start = microtime(true);
      if (substr($_criteria, 0, 2) == 'L:')
      {
        /* request for a cached search */
        $searches = $this->listCachedSearches();
        $name = substr($_criteria, 2);
        if (array_key_exists($name, $searches))
        {
          /* we recognize this as a cached seach */
          $_flags['L:searchName'] = $name;
          $_criteria = $searches[$name]['CRITERIA'];
          $_entityName = $searches[$name]['ENTITY'];
          $result = $this->_getSearchFromCache($name);
        } else return array();
      }
      if (is_array($result)) 
      {
        /* this result is a cached report, get referenced objects */
        $result = $this->getObjects($result, $_detail);
      } else 
        { 
          /* perform search via RPC */
          $result = array();
          $params = array(new XML_RPC_Value($_entityName, 'string'),
                           $this->wrap($_criteria),
                           new XML_RPC_Value($_detail, 'int'),
                           $this->wrap($_flags));
          $message = new XML_RPC_Message('zogi.searchForObjects', $params);
          $rpc_start = microtime(true);
          $response = $this->client->send($message);
          syslog(LOG_DEBUG, sprintf('zOGI Search RPC returned in %f seconds',
                                    (microtime(true) - $rpc_start)));
          $this->rpc_time += (microtime(true) - $start);
          if ($response->faultCode() == 0)
          {
            $result = $this->unwrap($response->value());
            if ($result == null)
              syslog(LOG_DEBUG, 
                     sprintf('zOGI received invalid XML response: %s',
                             $response->serialize()));
          } else 
            {
              syslog(LOG_WARNING,
                     sprintf('zOGI recevied an XML-RPC fault (%d: %s)',
                             $response->faultCode(),
                             $response->faultString()));
                              
            }
          if ($this->cache)
            foreach($result as $object)
              $this->_putToCache($object, $_detail);
        }
      if (array_key_exists("L:searchName", $_flags)) {
        $ids = array();
        foreach($result as $object)
          array_push($ids, $object['objectId']);
        $this->_putSearchToCache($_flags['L:searchName'], 
                                 $ids, 
                                 $_criteria,
                                 $_entityName);
      }
      syslog(LOG_DEBUG, sprintf('zOGI Search complete in %f seconds',
                                (microtime(true) - $start)));
      return $result;
    } /* end searchForObjects */

    function listCachedSearches()
    {
      return $this->_getSearchsFromCache();
    }

    /* Get the list of favorite objects 
       http://code.google.com/p/zogi/wiki/getFavoritesByType */
    function getFavoritesByType($_entityName, $_detail = 0)
    {
      $params = array(new XML_RPC_Value($_entityName, 'string'),
                       new XML_RPC_Value($_detail, 'int'));
      $message = new XML_RPC_Message('zogi.getFavoritesByType', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    } /* end getFavoritesByType */

    /* Mark objects as favorites
       http://code.google.com/p/zogi/wiki/flagFavorites */
    function flagFavorites($_favIds)
    {
      if (is_array($_favIds))
        $params = array(new XML_RPC_Value($_favIds, 'array'));
      else 
        $params = array(new XML_RPC_Value($_favIds, 'string'));
      $message = new XML_RPC_Message('zogi.flagFavorites', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    } /* end flagFavorites */

    /* Remove favorite status from objects 
       http://code.google.com/p/zogi/wiki/unflagFavorites */
    function unflagFavorites($_favIds)
    {
      if (is_array($_favIds))
        $params = array(new XML_RPC_Value($_favIds, 'array'));
      else  
        $params = array(new XML_RPC_Value($_favIds, 'string'));
      $message = new XML_RPC_Message('zogi.unflagFavorites', $params);
      $response = $this->client->send($message);
      return $this->unwrap($response->value());
    } /* end unflagFavorites */

    /* Get a subkey reference 
       WARNING: PHP is a stupid and clumsy language,  you need
                to indicate pass-by-reference for both the function
                declaration AND on the receiver.  Ick!
       http://us.php.net/manual/en/language.references.return.php 
       http://code.google.com/p/zogi/wiki/PHP */
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
    } /* end getSubkeyReference */

    /****************** PRIVATE METHODS *******************/

    /* PRIVATE METHOD */
    function _getFromCache($_objectId, $_detail)
    {
      if ($this->cache)
      {
        $this->check_count++;
        $result = $this->cache->get(
           sprintf('%d:%d',
             $this->getLoginAccountId(),
             $_objectId));
      }
      if(isset($result['objectId']))
      {
        /* Object existed in cache, we need to check detail level */
        if (intval($result['_detail']) == 65535)
        {
          $this->hit_count++;
          return $result;
        }
        //if(intval($result['_detail']) == intval($_detail))
        if (((intval($_detail)) & ~(intval($result['_detail']))) == 0)
        {
          $this->hit_count++;
          return $result;
        } else
          {
            syslog(LOG_DEBUG, 
                   sprintf("cached objectId#%d had incorrect detail level",
                     $_objectId));
          }
      }
      return false;
    }    

    /* PRIVATE METHOD */
    function _putToCache($_object, $_detail)
    {
      if ($this->cache)
      {
        $_object['_detail'] = $_detail;
        $this->cache->set(
          sprintf('%d:%d',
            $this->getLoginAccountId(),
            $_object['objectId']),
          $_object,
          0,
          300);
      }
    } /* end _putToCache */

    /* PRIVATE METHOD */
    function _putSearchToCache($_name, $_ids, $_criteria, $_entityName)
    {
      syslog(LOG_DEBUG, sprintf('zOGI storing search %s in cache', $_name));
      if ($this->cache)
      {
        $this->cache->set(
          sprintf('%d:%s',
            $this->getLoginAccountId(),
            $_name),
          $_ids,
          0,
          300);
        $search = array();
        $search['CRITERIA'] = $_criteria;
        $search['COUNT'] = count($_ids);
        $search['ENTITY'] = $_entityName;
        $search['STAMP'] = microtime(true);
        $search['NAME'] = $_name;
        $searchs = $this->_getSearchsFromCache();
        $searchs[$_name] = $search;
        $this->_putSearchsToCache($searchs);
      }
    } /* end _putSearchToCache */

    function _getSearchsFromCache()
    {
      $searches = array();
      if ($this->cache)
      {
        $key = sprintf('%d:%s', $this->getLoginAccountId(), '*SEARCHES');
        $searches = $this->cache->get($key);
      }
      return $searches;
    }

    function _putSearchsToCache($_searches)
    {
      if ($this->cache)
      {
        $key = sprintf('%d:%s', $this->getLoginAccountId(), '*SEARCHES');
        $searches = $this->cache->set($key, $_searches);
      }
    }

    /* PRIVATE METHOD */
    function _getSearchFromCache($_name)
    {
      if ($this->cache)
      {
        $result = $this->cache->get(
           sprintf('%d:%s',
             $this->getLoginAccountId(),
             $_name));
      }
      return $result;
    } /* end _getSearchFromCache */

    /* PRIVATE METHOD */
    function _removeFromCache($_object)
    {
      if ($this->cache)
      {
        if (is_array($_object))
        {
          $this->cache->delete(
            sprintf('%d:%d',
              $this->getLoginAccountId(),
              intval($_object['objectId'])));
        } else
          {
            $this->cache->delete(
              sprintf('%d:%d',
                $this->getLoginAccountId(),
                intval($_object)));
          }
      }
    } /* end _removeFromCache */

    /* PRIVATE METHOD */
    function _rippleCache($_object, $_cause)
    {
      $count = 0;
      if (is_array($_object))
      {
        foreach ($_object as $key => $value)
        {
          if (substr($key, 0, 1) == '_') 
          {
            if (is_array($value))
              $count += $this->_purgeTargets($value);
          }
        }
        syslog(LOG_DEBUG, sprintf("zOGI cache ripple purged %d objects",
                            $count));
      } else syslog(LOG_ERR, 'zOGI cache ripple given a non-array');
    } /* end _rippleCache */

    /* PRIVATE METHOD */
    function _purgeTargets($_object)
    {
      $count = 0;
      foreach ($_object as $entity)
        if (is_array($entity))
        {
          foreach ($entity as $key => $value)
            if (($key == 'targetObjectId') ||
                ($key == 'enterpriseObjectId') || 
                ($key == 'contactObjectId') ||
                ($key == 'objectId') ||
                ($key == 'creatorObjectId') ||
                ($key == 'sourceObjectId') ||
                ($key == 'parentObjectId'))
            {
              $this->_removeFromCache($value);
              $count++;
            }
        }
      return $count;
    } /* end _purgeTargets */

    /* PRIVATE METHOD */
    function unwrap($value) 
    {
      if (is_object($value)) 
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
      } else 
        {
          syslog(LOG_ERR, 
                 sprintf('unwrap encountered a non-object of type %s',
                         gettype($value)));
          return null;
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
