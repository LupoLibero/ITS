var Type        = require('couchtypes/types').Type;
var permissions = require('couchtypes/permissions');

exports.Subscription = function () {
  return new Type('subscription', {
    permissions: {
      add:    permissions.loggedIn(),
      update: permissions.usernameMatchesField('subscriber'),
      remove: permissions.usernameMatchesField('subscriber'),
    },
    fields: {
      subscriber: fields.string(),
      object_key: fields.string(),
    },
  });
};
