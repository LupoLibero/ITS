var Type        = require('couchtypes/types').Type;
var permissions = require('couchtypes/permissions');
var idField     = require('../ITS/fields').idField;

exports.Subscription = function () {
  return new Type('subscription', {
    permissions: {
      add:    permissions.loggedIn(),
      update: permissions.usernameMatchesField('subscriber'),
      remove: permissions.usernameMatchesField('subscriber'),
    },
    fields: {
      id: idField(/<object_key>\-<subscriber>/),
      subscriber: fields.string(),
      object_key: fields.string(),
    },
  });
};
