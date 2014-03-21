var Type        = require('couchtypes/types').Type;
var fields      = require('couchtypes/fields');
var widgets     = require('couchtypes/widgets');
var permissions = require('couchtypes/permissions');
var _           = require('underscore');
var votingField = require('../Vote/fields').votingField;


exports.authorCantVote = function() {
  return function (newDoc, oldDoc, newValue, oldValue, userCtx) {
    if (userCtx.name == newDoc.author) {
      throw new Error('Author can\'t vote for his comment');
    }
  }
}


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
      votes: votingField({
        permissions: {
          update: exports.authorCantVote()
        }
      })
    }
  });
}
