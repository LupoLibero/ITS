var Type              = require('couchtypes/types').Type;
var fields            = require('couchtypes/fields');
var widgets           = require('couchtypes/widgets');
var permissions       = require('couchtypes/permissions');
var _                 = require('underscore');
var translatableField = require('../Translation/fields').translatableField;
var activityField     = require('../Activity/fields').activityField;
var votingField       = require('../Vote/fields').votingField;
var idField           = require('../ITS/fields').idField;




exports.card = new Type('card', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.loggedIn(),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    author:     fields.creator(),
    created_at: fields.createdTime(),
    updated_at: fields.number({
      required: false
    }),
    id: idField(/<project_id>\.\d+/),
    init_lang: fields.string(),
    project_id: fields.string(),
    description: translatableField({
      required: false,
    }),
    title: translatableField(),
    list_id: fields.string(),
    tag_list: fields.array(),
    votes: votingField(),
    activity: activityField(),
  },
});


exports.card_list = new Type('card_list', {
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


exports.cost_estimate = new Type('cost_estimate', {
  permissions: {
    add: permissions.hasRole('dev'),
    update: permissions.hasRole('dev'),
    remove: permissions.hasRole('dev')
  },
  fields: {
    project_id: fields.string(),
    estimate: fields.number(),
    //id: fields.string(),
    card_id: fields.string(),
  }
});

exports.payment = new Type('payment', {
  permissions: {
    add: permissions.hasRole('_admin'),
    update: permissions.hasRole('_admin'),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    project_id: fields.string(),
    amount: fields.number(),
    card_id: fields.string(),
  }
});
