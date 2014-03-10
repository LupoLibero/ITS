var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');
var translatableField = require('../Translation/fields').translatableField;


exports.Project = function () {
  return new Type('project', {
    permissions: {
      add: permissions.hasRole('_admin'),
      update: permissions.hasRole('_admin'),
      remove: permissions.hasRole('_admin')
    },
    fields: {
      id: fields.string(),
      name: translatableField(),
      init_lang: fields.string({
        required: false
      }),
      description: translatableField({
        required: false
      })
    }
  });
}
