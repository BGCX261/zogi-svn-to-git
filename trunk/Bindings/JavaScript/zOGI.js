function zOGI() {
  function doRequest() {
    var jsonData;

		Ext.Ajax.request({
			url : 'ajax.php' , 
			params : { action : 'getDate' },
			method: 'GET',
			success: function ( result, request) {
        try {
          jsonData = Ext.util.JSON.decode(stringData);
        } catch (err) {
           Ext.MessageBox.alert('ERROR', 'Could not decode ' + result.responseText);
          }
			},
			failure: function ( result, request) { 
				Ext.MessageBox.alert('ERROR', 'AJAX/JSON operation failed'); 
			} 
		});
    return jsonData;
	} /* end doRequest */

  return {
    var username = undefined;
    var password = undefined;
    var hostname = undefined;

    init: function() {
    },
    authenticate: function(_username, _password, _hostname) {
      var response = doRequest({ method: 'auth', 
                                 params: { username: _username,
                                           password: _password,
                                           hostname: _hostname } });
      if (response == undefined) {
        // authentication failed
        username = undefined;
        password = undefined;
        hostname = undefined;
        return 0;
      } else {
          username = _username;
          password = _password;
          hostname = _hostname;
          return 1;
        }
    } /* end authenticate */
    putObject: function(_object) {
      var response = doRequest({ method: 'put',
                                 params: { sername: _username,
                                           password: _password,
                                           hostname: _hostname,
                                           object: _object } });
      return response;
    } /* end putObject */
    getObject: function(_objectId, _detail) {
      var response =  doRequest({ method: 'get',
                                 params: { sername: username,
                                           password: password,
                                           hostname: hostname,
                                           objectId: _objectId,
                                           detail: _detail } });
      return response;
    } /* end getObject */
    removeObject: function(_objectId) {
      var response =  doRequest({ method: 'remove',
                                 params: { sername: username,
                                           password: password,
                                           hostname: hostname,
                                           objectId: _objectId } });
      return response;
    } /* end removeObject */
    descriptionOf: function(_objectId) {
      return 'Object description';
    }
  }
}


