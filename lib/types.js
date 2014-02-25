var Type = require('couchtypes/types').Type,
    fields = require('couchtypes/fields'),
    widgets = require('couchtypes/widgets'),
    permissions = require('couchtypes/permissions');


function assert(assertion, message) {
  if(assertion === false)
    throw new Error(message || 'unauth');
}

function unchanged(newDoc, oldDoc, field, message) {
  if (oldDoc && oldDoc[field] !== undefined
      && toJSON(oldDoc[field]) != toJSON(newDoc[field])
      && !isDbAdmin())
    throw new Error(message || 'changed_' + field);
}

function votes_validation(newDoc, oldDoc, newValue, oldValue, userCtx) {
  var name, voter, newRank, oldRank;
  function isVoter(name) {
    return userCtx.name == name;
  }
  function voterAlreadyFound() {
    return voter !== undefined;
  }
  newRank = Object.keys(newValue).length;
  oldRank = Object.keys(oldValue).length;
  log("votes_validation");
  if (newRank == oldRank) {
    unchanged(newDoc, oldDoc, 'votes', "Same rank but different votes");
  }
  else {
    if (newRank > oldRank) {
      assert(newRank == oldRank + 1, "Adding more than one vote at a time");
      for (name in newValue) {
        if (!oldValue.hasOwnProperty(name) || oldValue[name] !== newValue[name]) {
          assert(isVoter(name), "You can't vote for someone else");
          assert(!voterAlreadyFound(), "Too many changes in votes");
          voter = name;
        }
      }
    }
    else {
      assert(newRank == oldRank - 1, "Removing more than one vote at a time")
      for (name in oldValue) {
        if (!newValue.hasOwnProperty(name) || newValue[name] !== oldValue[name]) {
          assert(isVoter(name), "You can't delete someone else's vote");
          assert(!voterAlreadyFound(), "Too many changes in votes");
          // removed voter
          voter = name;
        }
      }
    }
  }
}

function votes_field (options) {
  options = options || {};
  if (!options.permissions) {
      options.permissions = {};
  }
  var p = options.permissions;
  return new fields.Field({
    permissions: {
      add: permissions.all([function (newDoc, oldDoc, newValue, oldValue, userCtx) {
        var voter;
        for (voter in newValue) {
          assert(voter == userCtx.name, "You can't vote for someone else");
        }
      }].concat(p.add)),
      update: permissions.all([votes_validation].concat(p.update)),
    }
  });
}

// Project
exports.project = new Type('project', {
  permissions: {
    add: permissions.hasRole('_admin'),
    update: permissions.hasRole('_admin'),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    id: fields.string(),
    name: fields.string(),
    prefix: fields.string()
  }
})

// Demand
exports.demand = new Type('demand', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.loggedIn(),//.usernameMatchesField('author'),
    remove: permissions.hasRole('_admin')
  },
  fields: {
    author: fields.creator(),
    category: fields.string(),
    created_at: fields.createdTime(),
    id: fields.string({
      validators: [function(doc, value) {
          var id = value.split('#');
          if (id[0] !== doc.project_id.toUpperCase() || isNaN(id[1])) {
            throw new Error('Incorrect id');
          }
        }]
    }),
    project_id: fields.string(),
    status: fields.string(),
    title: fields.string(),
    votes: votes_field()
  }
})

// Comment
exports.comment = new Type('comment', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.any([
      permissions.usernameMatchesField('author'),
      permissions.hasRole('_admin')
    ]),
    remove: permissions.any([
      permissions.usernameMatchesField('author'),
      permissions.hasRole('_admin')
    ]),
  },
  fields: {
    author: fields.creator(),
    created_at: fields.createdTime(),
    demand_id: fields.string({
      permissions: {
        update: permissions.fieldUneditable()
      }
    }),
    message: fields.string(),
    votes: votes_field({
      permissions: {
        update: function (newDoc, oldDoc, newValue, oldValue, userCtx) {
          assert(!newValue.hasOwnProperty(userCtx.name), 'Author can\'t vote for his comment');
        }
      }
    })
  }
});
