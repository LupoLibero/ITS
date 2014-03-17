var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');
var _                 = require('underscore');
var translatableField = require('../Translation/fields').translatableField;
var activityField     = require('../Activity/fields').activityField;
var votingField        = require('../Voting/fields').votingField;

exports.demand = new Type('demand', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.loggedIn(),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    author: fields.creator(),
    created_at: fields.createdTime(),
    updated_at: fields.number({
      required: false
    }),
    id: fields.string({
      validators: [function(doc, value) {
          var id = value.split('#');
          if (id[0] !== doc.project_id.toUpperCase() || isNaN(id[1])) {
            throw new Error('Incorrect id');
          }
        }]
    }),
    init_lang: fields.string({
      required: false
    }),
    project_id: fields.string(),
    description: translatableField({
      required: false,
    }),
    title: translatableField(),
    list_id: fields.string(),
    votes: votingField(),
    activity: activityField(),
  },
});


exports.demand_list = new Type('demand_list', {
  permissions: {
    add: permissions.hasRole('_admin'),
    update: permissions.hasRole('_admin'),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    project_id: fields.string(),
    name: translatableField(),
    id: fields.string()
  }
});
