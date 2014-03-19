var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');

exports.cost_estimate = new Type('vote', {
  permissions: {
    add:    permissions.loggedIn(),
    update: permissions.usernameMatchesField('voter'),
    remove: permissions.usernameMatchesField('voter'),
  },
  fields: {
    voter:         fields.creator(),
    vote:          fields.boolean(),
    id:            fields.string(),
    voted_doc_id:  fields.string(),
  }
});
