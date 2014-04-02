var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');
var idField           = require('../ITS/fields').idField;

exports.vote = new Type('vote', {
  permissions: {
    add:    permissions.hasRole('dev'),
    update: permissions.usernameMatchesField('voter'),
    remove: permissions.usernameMatchesField('voter'),
  },
  fields: {
    voter:         fields.creator(),
    vote:          fields.boolean(),
    id:            idField(/<voted_doc_id>\-<author>/),
    voted_doc_id:  fields.string(),
  }
});
