var _                   = require('underscore')._;
var fields              = require('lib/types');
var hasRole             = require('lib/utils').hasRole;
var registerTranslation = require('../Translation/utils').registerTranslation;
var updateActivity      = require('../Activity/utils').updateActivity;

exports.demand_create = function(doc, req) {
  var date = new Date().getTime();
  var attr;
  var form = JSON.parse(req.body);
  if(doc !== null){
    throw({forbidden: 'New demand only'});
  } else {
    form.type        = 'demand';
    form._id         = form.type + '-' + form.id;
    form.author      = req.userCtx.name;
    form.status      = "draft";
    form.created_at  = date;
    form.votes       = {};
    form.description = {};
    form.activity    = [];
    form.init_lang   = form.lang;
    registerTranslation(form, form, 'demand', 'title', form.lang);
    // Add the vote of the creator
    form.description[form.lang]  = '';
    form.votes[req.userCtx.name] = true;
    delete form.lang;
    return ([form, 'ok']);
  }
}

exports.demand_update_field = function (doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    if (!form.hasOwnProperty('element') ||
        !form.hasOwnProperty('value')   ||
        !form.hasOwnProperty('_rev')
    ) {
      throw({forbidden: 'Request incomplete'});
    }
    if (doc._rev !== form._rev) {
      var vers = parseInt(form._rev.split('-')[0]);
      for (key in doc.activity) {
        act = doc.activity[key];
        if(
          act[0] == form.element &&
          parseInt(act[3].split('-')[0]) >= vers
        ) {
          throw({forbidden: 'Already modify'});
        }
      }
    }

    doc.updated_at = new Date().getTime();
    updateActivity(doc, req, form.element, form._rev);
    if (fields['demand'].fields[form.element].translatable) {
      registerTranslation(doc, form, 'demand', form.element, form.lang);
    } else {
      doc[form.element] = form.value;
    }

    return [doc, 'ok'];
  }
  throw({forbidden: 'Not for demand creation'});
}

exports.demand_vote = function(doc, req) {
  if(doc != null) {
    if(hasRole(req.userCtx, 'sponsor')){
      throw new Error('You need to be a sponsor for voting' || 'unauth');
      return false;
    }
    doc.updated_at = new Date().getTime();
    updateActivity(doc, req, 'votes');
    doc.votes[req.userCtx.name] = true;
    return [doc, 'ok'];
  }
}

exports.demand_cancel_vote = function(doc, req) {
  if(doc != null) {
    if(!hasRole(req.userCtx, 'sponsor')){
      throw new Error('You need to be a sponsor for voting' || 'unauth');
      return false;
    }
    doc.updated_at = new Date().getTime();
    updateActivity(doc, req, 'votes');
    delete doc.votes[req.userCtx.name];
    return [doc, 'ok'];
  }
}

