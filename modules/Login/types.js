var Type        = require('couchtypes/types').Type;
var fields      = require('couchtypes/fields');
var permissions = require('couchtypes/permissions');
var md5         = require('md5');
var utils       = require('../ITS/utils');
var assert      = utils.assert;

exports.user = new Type('user', {
  permissions: {
    update: permissions.usernameMatchesField('name'),
    remove: permissions.any([
      permissions.usernameMatchesField('name'),
      permissions.hasRole('_admin')
    ]),
  },
  fields: {
    created_at: fields.createdTime(),
    email: fields.email(),
    id: fields.string(),
    name: fields.string({
      validators: [
        function(doc, value) {
          assert(value == doc.id, "User.name must be equal to User.id");
        }],
    }),
    email_validation_token: fields.string({
      required: false,
      permissions: {
        remove: permissions.hasRole('superadmin')
      }
    }),
    email_validated: fields.boolean({
      permissions: {
        update: function (newDoc, oldDoc, newValue, oldValue, userCtx) {
          assert(newValue === true);
          assert(newDoc.hasOwnProperty('email_validation_token'), "email_validation_token must exist");
          assert(md5.hex(newDoc.email_validation_token) == oldDoc.email_validation_token, "Incorrect email validation token");
        },
      }
    }),
  }
});
