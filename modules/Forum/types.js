var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');
var translatableField = require('../Translation/fields').translatableField;


exports.forum = function () {
  return new Type('forum', {
    permissions: {
      add: permissions.hasRole('_admin'),
      update: permissions.hasRole('_admin'),
      remove: permissions.hasRole('_admin')
    },
    fields: {
      id: fields.string(),
      name: translatableField(),
      description: translatableField({
        required: false
      })
    }
  });
};

exports.forum_message = function () {
  return new Type('forum_message', {
    permissions: {
      add: permissions.loggedIn(),
      update: permissions.usernameMatchesField('author'),
      remove: permissions.any([
        permissions.usernameMatchesField('author'),
        permissions.hasRole('_admin')
      ]),
    },
    fields: {
      id: fields.string(),
      forum_id: fields.string(),
      thread_id: fields.string(),
      parent_id: fields.string({
        required: false
      }),
      author: fields.creator(),
      message: fields.string(),
      created_at: fields.createdTime(),
    }
  })
}
