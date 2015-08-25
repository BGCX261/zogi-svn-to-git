<?php
/**
 * Turba directory driver implementation for zOGI/OpenGroupware
 *
 * @author  Adam Tauno Williams <awilliam@whitemice.org>
 * @package Turba
 */

require_once('ZOGI.php');
class Turba_Driver_zogi extends Turba_Driver {
    var $_server = null;
    var $_limit = 50;
    var $_entity = 'Contact';

    function Turba_Driver_pogi($params)
    {
        parent::Turba_Driver($params);
    }

    function _init() {
        $this->_server = new ZOGI();
        $this->_limit = $this->_params['limit'];
        $this->_entity = $this->_params['entity'];
        if (!($this->_server->connect(Auth::getAuth(), 
                                      Auth::getCredential('password')))) {
            return PEAR::raiseError(_('Connection failure'));
        }
        return;
    }

    function _search($criteria, $fields)
    {
      /**
       *   CRITERIA=Array ( [AND] => Array 
       *                       ( [0] => Array ( [field] => nickname 
       *                                        [op] => LIKE 
       *                                        [test] => adam ) 
       *                         [1] => Array ( [field] => firstname 
       *                                        [op] => LIKE 
       *                                        [test] => adam ) 
       *                         [2] => Array ( [field] => name 
       *                                        [op] => LIKE 
       *                                        [test] => williams ) ) ) 
       *    FIELDS=Array ( [0] => object_id 
       *                   [1] => nickname 
       *                   [2] => firstname 
       *                   [3] => name 
       *                   [4] => url 
       *                   [5] => extendedAttrs/email1 ) 
       */
         foreach ($criteria['AND'] as $each) {
             $criterion = array();
             $criterion['conjunction'] = 'AND';
             $criterion['attribute'] = $each['field'];
             if ($each['op'] == 'LIKE') {
                 $criterion['expression'] = 'ILIKE';
                 $criterion['value'] = sprintf('%%%s%%', $each['test']);
             } else {
                   $criterion['expression'] = 'EQUALS';
                   $criterion['value'] = $each['test'];
               }
             array_push($criteria, $criterion);                  
         }
         $result = $this->_server->search($this->_entity,
                                          $criteria,
                                          8,
                                          array('limit' => $this->_limit));
         return $this->_getResults($fields, $result);
    }

    /**
     * Retrieves the specified object from the OGo server
     *
     * @param string $criteria  Search criteria (must be 'objectId').
     * @param mixed  $objectId  The primary key of the object to retrieve
     * @param array  $fields    List of fields to return.
     *
     * @return array  Hash containing the search results.
     */
    function _read($criteria, $objectIds, $fields)
    {
        /* Only objectId. */
        if ($criteria != 'object_id') {
            return array();
        }

        $results = $this->_server->getObjects($objectIds);
        return $this->_getResults($fields, $results);
    }

    function _getResults($fields, $res)
    {
      $results = array();
      foreach($res as $result)
        array_push($results, $this->_getResult($fields, $result));
      return $results;
    }

    /**
     * Get some results from a result identifier and clean them up.
     *
     * @param array    $fields  List of fields to return.
     * @param resource $results RPC results
     *
     * @return array  Hash containing the results.
     */
    function _getResult($fields, $result) {
      $document = array();
      $document['objectId'] = $result['objectId'];
      foreach($fields as $field)
      {
        $key = explode(".", $field);
        switch($key[0])
        {
          case 'address':
            $typeKey = $key[1];
            $localKey = $key[2];
            $addr = &$this->_server->getSubkeyReference($result, 
                                                        '_ADDRESSES', 
                                                        'type', 
                                                        $typeKey);
            $phone[$field] = $address[$localKey];
           break;
          case 'phone':
            $typeKey = $key[1];
            $localKey = $key[2];
            $phone = &$this->_server->getSubkeyReference($result, 
                                                         '_PHONES', 
                                                         'type', 
                                                         $typeKey);
            $document[$field] = $phone[$localKey];
           break;
          case 'xa':
            $attribute = $key[1];
            $xa = &$this->_server->getSubkeyReference($result, 
                                                      '_COMPANYVALUES', 
                                                      'attribute', 
                                                      $attribute);
            $document[$field] = $xa['value'];
           break;
          default:
            $document[$field] = $result[$field];
           break;
        }
      }
    }

    function _add($attributes) {
        return $this->putObject($attributes);
    }

    function _delete($object_key, $object_id) {
        return $this->_server->removeObject($object_id);
    }

    function _save($object_key, $object_id, $attributes) {
        /**
          KEY=object_id
          ID=1978060
          ATTRIBUTES=Array ( [object_id] => 1978060 
                             [nickname] => HAROLD WILLIAMS X165 
                             [firstname] => HAROLD 
                             [name] => WILLIAMS 
                             [url] => 
                             [xa/email1] => 
                             [xa/job_title] => PARTS MANAGER 
                             [phone/01_tel/number] => 770-939-1970 
                             [phone/03_tel_funk/number] => 
                             [phone/10_fax/number] => 770-938-6302 
                             [address/location/line1] => MAINTENANCE EQUIPMENT CO 
                             [address/location/line2] => ATTN: HAROLD WILLIAMS X165 
                             [address/location/line3] => 
                             [address/location/street] => PO BOX 385 
                             [address/location/city] => ATLANTA 
                             [address/location/state] => GA 
                             [address/location/zip] => 30085-0385 ) 
         **/
    }

}

