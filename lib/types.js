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


exports.votes_validation = function (newDoc, oldDoc, newValue, oldValue, userCtx) {
  var name, voter, newRank, oldRank;
  function isVoter(name) {
    log(name)
    log(userCtx.name)
    return userCtx.name == name;
  }
  function voterAlreadyFound() {
    return voter !== undefined;
  }
  newRank = Object.keys(newValue).length;
  oldRank = Object.keys(oldValue).length;
  log("votes_validation");
  log(newRank);
  log(oldRank);
  if (newRank == oldRank) {
    assert(toJSON(newValue) == toJSON(oldValue), "Same rank but different votes");
  }
  else {
    if (newRank > oldRank) {
      assert(newRank == oldRank + 1, "Adding more than one vote at a time");
      for (name in newValue) {
        if (!oldValue.hasOwnProperty(name) || oldValue[name] !== newValue[name]) {
          assert(isVoter(name), "You can\'t vote for someone else");
          assert(!voterAlreadyFound(), "Too many changes in votes");
          voter = name;
        }
      }
    }
    else {
      assert(newRank == oldRank - 1, "Removing more than one vote at a time")
      for (name in oldValue) {
        if (!newValue.hasOwnProperty(name) || newValue[name] !== oldValue[name]) {
          assert(isVoter(name), "You can\'t delete someone else's vote");
          assert(!voterAlreadyFound(), "Too many changes in votes");
          // removed voter
          voter = name;
        }
      }
    }
  }
}

exports.creationValidation = function (newDoc, oldDoc, newValue, oldValue, userCtx) {
  var voter;
  for (voter in newValue) {
    assert(voter == userCtx.name, "You can\'t vote for someone else");
  }
}

exports.authorCantVote = function (newDoc, oldDoc, newValue, oldValue, userCtx) {
  log(newValue)
  assert(!newValue.hasOwnProperty(userCtx.name), 'Author can\'t vote for his comment');
}

exports.votes_field = function (options) {
  log(options);
  options = options || {};
  if (!options.permissions) {
      options.permissions = {};
  }
  var p = options.permissions;
  if (p.add) {
    p.add = permissions.all(
      exports.creationValidation,
      p.add
    );
  }
  else {
    p.add = exports.creationValidation;
  }
  if (p.update) {
    p.update = permissions.all(
      exports.votes_validation,
      p.update
    );
  }
  else {
    p.update = exports.votes_validation;
  }
  return new fields.Field({
    permissions: {
      add: p.add,
      update: p.update
    }
  });
}

function activity_field () {
  var CHANGE_ELEMENT = 0,
      CHANGE_AUTHOR = 1,
      CHANGE_DATE = 2,
      OLD_CONTENT = 3;
  var activityValidation = function (newDoc, oldDoc, newValue, oldValue, userCtx) {
    var lastActivity = newValue.pop();
    assert(newValue.length >= 0, "Activity must be saved on update");
    log(toJSON(newValue));
    log(toJSON(oldValue));
    assert(oldValue && toJSON(newValue) == toJSON(oldValue), "Old activity has been modified")
    assert(newDoc.hasOwnProperty(lastActivity[CHANGE_ELEMENT]) &&
           oldDoc.hasOwnProperty(lastActivity[CHANGE_ELEMENT]), "Change on a field that does not exist");
    assert(lastActivity[CHANGE_AUTHOR] == userCtx.name, "Change must be done by logged in user");
    assert(!isNaN(lastActivity[CHANGE_DATE]), "3rd element must be a timestamp");
    assert(lastActivity[OLD_CONTENT] == oldDoc[lastActivity[CHANGE_ELEMENT]], "Previous version is not correctly saved");
  }
  return new fields.Field({
    permissions: {
      update: activityValidation,
    }
  })
}

exports.activity = new Type('activity', {
  fields: {
    
  }
})

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

// Comment
exports.comment = new Type('comment', {
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
    demand_id: fields.string({
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
    votes: exports.votes_field({
      permissions: {
        update: exports.authorCantVote
      }
    })
  }
});

// Demand
exports.demand = new Type('demand', {
  permissions: {
    add: permissions.loggedIn(),
    update: permissions.loggedIn(),
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
    votes: exports.votes_field(),
    activity: activity_field(this)
  }
})

