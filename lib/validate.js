exports.validate_doc_update = function(newDoc, oldDoc, userCtx) {
  var e;
  function assert(assertion, message) {
    if(assertion === false)
      throw({forbidden: message || 'unauth'});
  }
  function require(field, message) {
    message = 'missing_' + field;
    //if (!newDoc[field]) throw({forbidden : message});
    assert(newDoc.hasOwnProperty(field), message)
  }
  function unchanged(field, message) {
    if (oldDoc && oldDoc[field] !== undefined
        && toJSON(oldDoc[field]) != toJSON(newDoc[field])
        && !isDbAdmin())
      throw({forbidden: message || 'changed_' + field});
  }
  var hasRole = function() {
    var roles = {};
    for(var i in userCtx.roles) {
      roles[userCtx.roles[i]] = null;
    }
    return function(role) {
      return role in roles;
    };
  }();
  function isLoggedIn() {
    return Boolean(userCtx.name);
  }
  function isLoggedInUser(username) {
    return username === userCtx.name;
  }
  function loginRequired() {
    assert(isLoggedIn(), 'loginreq');
  }
  function isAuthorized(username) {
    return isLoggedInUser(username) || hasRole(username) || isDbAdmin();
  }
  function authorizationRequired(username) {
    assert(isAuthorized(username));
  }
  function isDbAdmin() {
    return hasRole('_admin');
  }
  function isAdmin() {
    return isDbAdmin();
  }
  
  function votes_validation(newDoc, oldDoc, voting_field) {
    var k, name, voter, newRank, oldRank;
    function isVoter(name) {
      return userCtx.name == name;
    }
    function voterAlreadyFound() {
      return voter !== undefined;
    }
    newVotes = newDoc[voting_field];
    oldVotes = oldDoc !== null ? oldDoc[voting_field] : {};
    newRank = Object.keys(newVotes).length;
    oldRank = Object.keys(oldVotes).length;
    if (newRank == oldRank) {
      unchanged('votes', "Same rank but different votes");
    }
    else {
      if (newRank > oldRank) {
        assert(newRank == oldRank + 1, "Adding more than one vote at a time");
        for (name in newVotes) {
          //name = newVotes[k];
          if (!oldVotes.hasOwnProperty(name) || oldVotes[name] !== newVotes[name]) {
            assert(isVoter(name), "You can't vote for someone else");
            assert(!voterAlreadyFound(), "Too many changes in votes");
            voter = name;
          }
        }
      }
      else {
        assert(newRank == oldRank - 1, "Removing more than one vote at a time")
        for (name in oldVotes) {
          //name = oldVotes[k];
          if (!newVotes.hasOwnProperty(name) || newVotes[name] !== oldVotes[name]) {
            assert(isVoter(name), "You can't delete someone else's vote");
            assert(!voterAlreadyFound(), "Too many changes in votes");
            // removed voter
            voter = name;
          }
        }
      }
    }
  }
  
  require('_id');
  //require('type');
  unchanged('type');
  unchanged('id');
  switch(newDoc.type) {
    case 'project':
      loginRequired();
      require('id');
      unchanged('id');
      assert(newDoc['_id'] == 'project-' + newDoc['id'], '_id must be <"project-"+id>')
      break;
    case 'demand':
      loginRequired();
      require('id');
      unchanged('id');
      require('category');
      require('created_at');
      unchanged('created_at');
      //require('init_lang');
      //unchanged('init_lang');
      require('status');
      /*require('translatable');
      for(e in newDoc.translatable) {
        require(e);
        require(e + '_versions');
      }*/
      require('votes');
      votes_validation(newDoc, oldDoc, 'votes');
      require('activity');
      var lastActivity = doc.activity.pop();
      unchanged('activity');
      assert(newDoc.hasOwnProperty(lastActiviy[0] &&
             oldDoc.hasOwnProperty(lastActiviy[0]), "Change on a field that does not exist");
      assert(isLoggedInUser(lastActivity[1]), "Change must be done by logged in user");
      // TODO validate date
      assert(lastActivity[3] == oldDoc[lastActivity[0]], "Previous version is not correctly saved");
      (function (newDoc, oldDoc) {
        var lastActivity = doc.activity[doc.activity.length-1];
        assert()
      }(newDoc, oldDoc);
      /*if(oldDoc) {
        for(e in oldDoc._attachments) {
          if(!newDoc._attachments[e]) throw({forbidden: 'missing attachment_' + e});
        }
      }*/
      break;
    case 'comment':
      loginRequired();
      require('created_at');
      unchanged('created_at')
      require('message');
      require('demand_id');
      unchanged('demand_id')
      require('author');
      unchanged('author')
      assert(isLoggedInUser(newDoc.author), 'Can\'t create a comment for someone else');
      require('votes');
      votes_validation(newDoc, oldDoc, 'votes');
      assert(!newDoc.votes.hasOwnProperty('author'), 'Author can\'t vote for his comment')
      break;
  }
};
