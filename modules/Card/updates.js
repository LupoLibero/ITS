var _                   = require('underscore')._;
var fields              = require('lib/types');
var registerTranslation = require('../Translation/utils').registerTranslation;
var updateActivity      = require('../Activity/utils').updateActivity;

exports.card_create = function(doc, req) {
  var attr;
  var form = JSON.parse(req.body);
  if(doc !== null){
    throw({forbidden: 'New Card only'});
  } else {
    form.type        = 'card';
    form._id         = form.type + ':' + form.id;
    form.author      = req.userCtx.name;
    form.created_at  = new Date().getTime();
    form.votes       = {};
    form.description = {};
    form.activity    = [];
    form.list_id     = 'ideas';
    form.tag_list    = [];
    form.init_lang   = form.lang;
    registerTranslation(form, form, 'card', 'title', form.lang);
    // Add the vote of the creator
    form.description[form.lang]  = '';
    form.votes[req.userCtx.name] = true;
    delete form.lang;
    return ([form, 'ok']);
  }
}

exports.card_update_field = function (doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    if (!form.hasOwnProperty('element') ||
        !form.hasOwnProperty('value')   ||
        !form.hasOwnProperty('_rev')
    ) {
      throw({forbidden: 'Request incomplete'});
    }
    if (doc._rev !== form._rev) {
      var vers = parseInt(form._rev);
      for (key in doc.activity) {
        act = doc.activity[key];
        if(
          act[0] == form.element &&
          parseInt(act[3]) >= vers
        ) {
          throw({forbidden: 'Already modify'});
        }
      }
    }

    doc.updated_at = new Date().getTime();
    updateActivity(doc, req, form.element, form._rev);
    if (fields['card'].fields[form.element].translatable) {
      registerTranslation(doc, form, 'card', form.element, form.lang);
    } else {
      doc[form.element] = form.value;
    }

    return [doc, 'ok'];
  }
  throw({forbidden: 'Not for card creation'});
}