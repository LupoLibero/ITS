var fields      = require('couchtypes/fields');
var permissions = require('couchtypes/permissions');
var _           = require('underscore');
var utils       = require('lib/utils');
var assert      = utils.assert;

exports.votesValidation = function (newDoc, oldDoc, newValue, oldValue, userCtx) {
  var name, voter, newRank, oldRank;
  function isVoter(name) {
    return userCtx.name == name;
  }
  function voterAlreadyFound() {
    return voter !== undefined;
  }
  newRank = Object.keys(newValue).length;
  oldRank = Object.keys(oldValue).length;
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
  assert(!newValue.hasOwnProperty(userCtx.name), 'Author can\'t vote for his comment');
}

exports.votingField = function (options) {
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
      exports.votesValidation,
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
    },
  });
}
