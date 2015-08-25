<?php
/**
 * The Group_hooks:: class provides an OpenGroupare.org/zOGI backend
 * for the Horde group system
 *
 * Copyright 2008 Whitemice Consulting, Adam Tauno Williams
 *
 * See the enclosed file COPYING for license information (LGPL). If you
 * did not receive this file, see http://www.fsf.org/copyleft/lgpl.html.
 *
 * @author  Adam Tauno Williams <awilliam@whitemiceconsulting.com>
 * @package Horde_Group
 */
include_once('Horde/ZOGI.php');

class Group_zogi extends Group {

    var $_server = null;

    /**
     * Constructor.
     */
    function Group_zogi() {
        parent::Group();

        Horde::logMessage('created Group_zogi object',
                          __FILE__,
                          __LINE__,
                          PEAR_LOG_DEBUG);

        $this->_server = new ZOGI();
    }

		/**
     * Get a team entity from the server
     * 
     * @param integer  $teamId
     */
    function _getGroup($teamId) {
        if ($this->_server->connect(Auth::getAuth(), 
                                    Auth::getCredential('password'))) {
            $result = $this->_server->getObject($teamId, 256);
            if (is_a($result, 'PEAR_Error')) {
                PEAR::raiseError(_("Invalid object in zOGI response."));
                return false;
            }
            $team = array();
            $team['name'] = $result['name'];
            $team['guid'] = $result['objectId'];
            $team['users'] = array();
            foreach($result['_CONTACTS'] as $contact) {
                 if ($contact['isAccount'] == 1) {
                     array_push($team['users'], $contact['login']);
                 }
            }
            return $team;
        }
        return false;
    }

    /**
     * Get a list of every group that $user is in.
     *
     * @param string  $user          The user to get groups for.
     * @param boolean $parentGroups  Also return the parents of any groups?
     *
     * @return array  An array of all groups the user is in.
     */
    function getGroupMemberships($user, $parentGroups = false) {
        Horde::logMessage('getGroupMemberships',
                          __FILE__,
                          __LINE__,
                          PEAR_LOG_DEBUG);

        if ($this->_server->connect(Auth::getAuth(), 
                                    Auth::getCredential('password'))) {
            $groups = array();
            $criteria = array();
            array_push($criteria, array('conjunction' => 'AND',
                                        'key' => 'login',
                                        'value' => strtolower($user),
                                        'expression' => 'EQUALS')); 
            array_push($criteria, array('conjunction' => 'AND',
                                        'key' => 'isAccount',
                                        'value' => 1,
                                        'expression' => 'EQUALS'));
            $flags = array('limit' => 1,
                           'revolve' => 'NO');
            $result = $this->_server->search('Contact', 
                                             $criteria, 
                                             128, 
                                             $flags);
            if (is_array($result)) {
                $result = $result[0];
                if (is_array($result['_MEMBERSHIP'])) {
                    foreach($result['_MEMBERSHIP'] as $assignment) {
                        $teamId = $assignment['targetObjectId'];
                        $team = $this->_getGroup($teamId);
                        if (isset($team['name']))
                            array_push($groups, $team['name']);
                        else PEAR::raiseError(_("Invalid object in zOGI response."));
                    }
                }
            } else PEAR::raiseError(_("Invalid zOGI server version detected."));
        } else PEAR::raiseError(_("Cannot retrieve contacts teams."));
        Horde::logMessage(sprintf('User a member of %d groups', count($groups)),
                          __FILE__,
                          __LINE__,
                          PEAR_LOG_DEBUG);

        return $groups;
    }

    /**
     * Say if a user is a member of a group or not.
     *
     * @param string  $user       The name of the user.
     * @param integer $gid        The ID of the group.
     * @param boolean $subgroups  Return true if the user is in any subgroups
     *                            of $group, also.
     *
     * @return boolean
     */
    function userIsInGroup($user, $gid, $subgroups = true) {
        Horde::logMessage('userIsInGroup',
                          __FILE__,
                          __LINE__,
                          PEAR_LOG_DEBUG);

        $groups = $this->getGroupMemberships($user, false);
        return (in_array($gid, $groups) || parent::userIsInGroup($user, $gid, $subgroups));
    }

    /**
     *
     * @param object $gid        Ident of the group
     */
    function getLevel($gid) { return 0; }

}
