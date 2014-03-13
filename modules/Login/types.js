var Type        = require('couchtypes/types').Type;
var fields      = require('couchtypes/fields');
var permissions = require('couchtypes/permissions');
var md5         = require('md5');
var utils       = require('lib/utils');
var assert      = utils.assert;

exports.user = new Type('user', {
  permissions: {
    update: permissions.hasRole('_admin'),
    remove: permissions.any([
      permissions.usernameMatchesField('name'),
      permissions.hasRole('_admin')
    ]),
  },
  fields: {
    created_at: fields.createdTime(),
    email: fields.email(),
    id: fields.string(),
    email_validation_token: fields.string({
      required: false
    }),
    email_validated: fields.boolean({
      permissions: {
        update: function (newDoc, oldDoc, newValue, oldValue, userCtx) {
          log(["md5", md5.hex(newDoc.email_validation_token), oldDoc.email_validation_token]);
          assert(md5.hex(newDoc.email_validation_token) == oldDoc.email_validation_token, "Incorrect email validation token");
          assert(newValue === true);
        },
      }
    }),
  }
});
