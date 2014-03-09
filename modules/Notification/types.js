var Type        = require('couchtypes/types').Type;
var fields      = require('couchtypes/fields');
var permissions = require('couchtypes/permissions');

var idValidator = function(doc, value) {
  var _id = doc._id.split('--');
  if (_id[1] !== doc.object_key || _id[2] !== doc.subscriber) {
    throw new Error('Incorrect id');
  }
}

exports.subscription = new Type('subscription', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.usernameMatchesField('subscriber'),
    remove: permissions.usernameMatchesField('subscriber'),
  },
  fields: {
    object_key: fields.string({
      validators: [idValidator]
    }),
    subscriber: fields.creator(),
  }
});

/*
 * basculer en validate.js
exports.notification = new Type('notification', {
  permissions: {
    add: permissions.hasRole('_admin'),
    update: permissions.hasRole('_admin'),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    subscriber: fields.string(),
    message: fields.string(),
    subject: fields.string(),
    created_at: fields.createdTime(),
    displayed: fields.boolean({
      default_value: function (req) {
        return false;
      },
      permissions: {
        update: permissions.usernameMatchesField('subscriber'),
      }
    })
  }
})
*/
