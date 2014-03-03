var couchtypes = require('couchtypes/types'),
    types = require('./types');

exports.validate_doc_update = function(newDoc, oldDoc, userCtx) {
  function assert(assertion, message) {
    if(assertion === false)
      throw({forbidden: message || 'unauth'});
  }
  function require(field, message) {
    message = 'missing_' + field;
    //if (!newDoc[field]) throw({forbidden : message});
    assert(newDoc.hasOwnProperty(field), message)
  }

  function unchanged(field, message) {
    if (oldDoc && oldDoc[field] !== undefined
        && toJSON(oldDoc[field]) != toJSON(newDoc[field])
        && !isDbAdmin())
      throw({forbidden: message || 'changed_' + field});
  }

  var hasRole = function() {
		var roles = {};
		for(var i in userCtx.roles) {
			roles[userCtx.roles[i]] = null;
		}
		return function(role) {
			return role in roles;
		};
	}();

  function isDbAdmin() {
		return hasRole('_admin');
	}

  require('_id');
  unchanged('type');
  if (newDoc.hasOwnProperty('id')) {
    assert(newDoc._id == newDoc.type + '-' + newDoc.id, '_id must be like "<type>-<id>"');
  }
  unchanged('id');
  if (!isDbAdmin) {
    couchtypes.validate_doc_update(types, newDoc, oldDoc, userCtx);
  }
};
