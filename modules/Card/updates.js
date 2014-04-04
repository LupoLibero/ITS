var _                   = require('underscore')._;
var fields              = require('../ITS/types');
var registerTranslation = require('../Translation/utils').registerTranslation;
var updateActivity      = require('../Activity/utils').updateActivity;

exports.card_create = function(doc, req) {
  var attr;
  var form = JSON.parse(req.body);
  if(doc !== null){
    throw({forbidden: '345: New Card only'});
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
    registerTranslation(form, form, 'card', 'title', form.lang, form.lang);
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
      throw({forbidden: '111: Request incomplete'});
    }
    if (doc._rev !== form._rev) {
      var vers = parseInt(form._rev);
      acts = doc.activity;
      for(var i = acts.length-1; 0 <= i; i--) {
        act = acts[i];
        if ( parseInt(act._rev) > vers) {
          if (
            act.author !== req.userCtx.name &&
            act.element === form.element
          ) {
            throw({forbidden: '001: Conflict'});
          }
        } else {
          break;
        }
      }
    }

    doc.updated_at = new Date().getTime();
    updateActivity(doc, req, form.element, form._rev);
    if (fields['card'].fields[form.element].translatable) {
      registerTranslation(doc, form, 'card', form.element, form.lang, form.from);
    } else {
      doc[form.element] = form.value;
    }

    return [doc, 'ok'];
  }
  throw({forbidden: '346: Not for card creation'});
}
