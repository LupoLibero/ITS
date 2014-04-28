var _                   = require('underscore')._;
var fields              = require('../ITS/types');
var registerTranslation = require('../Translation/utils').registerTranslation;
var updateActivity      = require('../Activity/utils').updateActivity;

exports.card_create = function(doc, req) {
  var form = JSON.parse(req.body);
  if(doc !== null){
    throw({forbidden: '345: New Card only'});
  } else {
    var author = req.userCtx.name;

    form.type        = 'card';
    form._id         = form.type+':'+form.id;
    form.author      = author;
    form.created_at  = new Date().getTime();
    form.votes       = {};
    form.description = {
      content: '',
      rev: 1,
    };
    form.activity    = [];
    form.list_id     = 'ideas';
    form.tag_list    = [];
    form.init_lang   = form.lang;

    registerTranslation(form, form, 'card', 'title', form.lang, form.lang);
    // Add the vote of the creator
    form.votes[author] = true;
    delete form.lang;
    return ([form, 'ok']);
  }
}

exports.card_update_field = function (doc, req) {
  var form   = JSON.parse(req.body);
  var author = req.userCtx.name;
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
            act.author !== author &&
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
    if (fields['card'].fields[form.element].translatable) {
      registerTranslation(doc, form, 'card', form.element, form.lang, form.from);
    } else {
      doc[form.element] = form.value;
    }

    updateActivity(doc, author, form.element);
    return [doc, 'ok'];
  }
  throw({forbidden: '346: Not for card creation'});
}
