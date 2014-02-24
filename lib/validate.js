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
  function loginRequired() {
    //if(!isLoggedIn())
    //  throw({forbidden: 'loginreq'})
    assert(isLoggedIn(), 'loginreq');
  }
  function isAuthorized(username) {
    log(username + " " + userCtx.name + " " + userCtx.roles);
    return isLoggedIn() && (userCtx.name == username || hasRole(username) || isDbAdmin());
  }
  function authorizationRequired(username) {
    //if(!isAuthorized(username))
    //  throw({forbidden: 'unauth'});
    assert(isAuthorized(username));
  }
  function isDbAdmin() {
    return hasRole('_admin');
  }
  function isAdmin() {
    return isDbAdmin();
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
      require('rank');
      require('votes');
      assert(newDoc.rank == Object.keys(newDoc.votes).length, 'error in rank');
      (function(newDoc, oldDoc) {
        if (!oldDoc) {
          oldDoc = {votes: {}, rank: 0};
        }
        var k, name, voter;
        function isVoter(name) {
          return userCtx.name == name;
        }
        function voterAlreadyFound() {
          return voter !== undefined;
        }
        if (newDoc.rank == oldDoc.rank) {
          unchanged('votes', "Same rank but different votes");
        }
        else {
          if (newDoc.rank > oldDoc.rank) {
            assert(newDoc.rank == oldDoc.rank + 1, "Adding more than one vote at a time");
            for (name in newDoc.votes) {
              //name = newDoc.votes[k];
              if (!oldDoc.votes[name]) {
                assert(!voterAlreadyFound(), "Too many changes in votes");
                assert(isVoter(name), "You can't vote for someone else");
                voter = name;
              }
            }
          }
          else {
            assert(newDoc.rank == oldDoc.rank - 1, "Removing more than one vote at a time")
            for (name in oldDoc.votes) {
              //name = oldDoc.votes[k];
              if (!newDoc.votes[name]) {
                assert(!voterAlreadyFound(), "Too many changes in votes");
                assert(isVoter(name), "You can't delete someone else's vote");
                // removed voter
                voter = name;
              }
            }
          }
        }
      })(newDoc, oldDoc);

      if(oldDoc) {
        for(e in oldDoc._attachments) {
          if(!newDoc._attachments[e]) throw({forbidden: 'missing attachment_' + e});
        }
      }
      break;
    case 'demand-comment':
      loginRequired();
      require('created_at');
      unchanged('created_at')
      require('message');
      require('demand_id');
      unchanged('demand_id')
      require('user');
      unchanged('user')
      break;
  }
};
