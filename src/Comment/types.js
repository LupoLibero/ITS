var Type        = require('couchtypes/types').Type;
var fields      = require('couchtypes/fields');
var widgets     = require('couchtypes/widgets');
var permissions = require('couchtypes/permissions');
var _           = require('underscore');
var idField     = require('../ITS/fields').idField;

exports.Comment = function () {
  return new Type('comment', {
    permissions: {
      add: permissions.loggedIn(),
      update: permissions.loggedIn(),
      remove: permissions.any([
        permissions.usernameMatchesField('author'),
        permissions.hasRole('_admin')
      ]),
    },
    fields: {
      id: idField(/<parent_id>\-<author>\-\w+/),
      author: fields.creator(),
      created_at: fields.createdTime(),
      parent_id: fields.string({
        permissions: {
          update: permissions.fieldUneditable()
        }
      }),
      message: fields.string({
        permissions: {
          update: permissions.any([
            permissions.usernameMatchesField('author'),
            permissions.hasRole('_admin')
          ])
        }
      }),
    }
  });
}
