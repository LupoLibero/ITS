var _ = require('underscore')._,
    fields = require('./types');

function updateActivity (doc, req, element, _rev) {
  if (!doc.hasOwnProperty('activity')) {
    doc.activity = [];
  }
  log("updateActivity");
  log(doc);
  doc.activity.push([
    element,
    req.userCtx.name,
    new Date().getTime(),
    _.clone(doc[element])
  ]);
  log(doc.activity);
  // this will result as a conflict if user had not last revision
  // must be handled client side
  // not needed in every case
  if (_rev) {
    doc._rev = _rev;
  }
}

function registerTranslation (doc, form, type, element, lang) {
  if (!doc.hasOwnProperty('translatableFields') ||
      !doc.translatableFields.hasOwnProperty(element)) {
    return
  }
  if (lang == undefined) {
    throw({forbidden: 'No language code'});
  }
  if (!doc[element]) {
    doc[element] = {}
  }
  if (!doc[element][lang]) {
    doc[element][lang] = {}
  }
  doc[element][lang] = form[element];
}


exports.vote = function(doc, req) {
  if(doc != null) {
    updateActivity(doc, req, 'votes');
    doc.votes[req.userCtx.name] = true;
    return [doc, 'ok'];
  }
}

exports.cancel_vote = function(doc, req) {
  if(doc != null) {
    updateActivity(doc, req, 'votes');
    delete doc.votes[req.userCtx.name];
    return [doc, 'ok'];
  }
}

exports.vote_comment_up = function(doc, req) {
  if(doc != null) {
    doc.votes[req.userCtx.name] = true;
    return [doc, 'ok'];
  }
}

exports.vote_comment_down = function(doc, req) {
  if(doc != null) {
    doc.votes[req.userCtx.name] = false;
    return [doc, 'ok'];
  }
}

exports.user = function(doc, req) {
	var form = JSON.parse(req.body)
	if(doc === null) {
		form.type = 'user';
		form.name = form.id;
		form._id = form.type + '-' + form.id;
		return [form, 'ok'];
	} else {
		if(form.item && form.data) {
			doc[form.item] = form.data;
			return [doc, 'ok'];
		}
	}
}

exports.demand_update_field = function (doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    if (!form.hasOwnProperty('element') ||
        !form.hasOwnProperty('value') ||
        !form.hasOwnProperty('_rev')) {
      throw({forbidden: 'Request incomplete'});
    }
    registerTranslation(doc, form, 'demand', form.element, form.lang);
    updateActivity(doc, req, form.element, form._rev);
    doc[form.element] = form.value;
  }
}

exports.logwork = function(doc, req) {
  var form = JSON.parse(req.body);
  if(doc === null) {
    form.type = 'worklog';
    form.declaredAt = new Date().toISOString();
    form.user = req.userCtx.name;
    form._id = req.uuid;
    return ([form, 'ok']);
  } else {

    return ([doc, 'ok']);
  }
};

exports.dependency = function(doc, req) {
  function saveNewVersion(doc, req, label, value, date) {
    var base64 = require('base64');
    var name;
    var previousValue = JSON.stringify(doc[label] !== undefined ? doc[label].value : null);
    doc[label] = {author: req.userCtx.name, date: date, value: value};
    doc.last_edit = date;
    if(!doc._attachments) {
      doc._attachments = {};
      doc.lastVersion = 0;
    }
    doc.lastVersion += 1;
    name = doc[label].date + "©" + doc[label].author + "©" + label;
    doc._attachments[name] = {
      content_type: 'text/json',
      data: base64.encode('[' + JSON.stringify(doc[label].value) + ',' + previousValue + ']')
    };
  }
  var form = JSON.parse(req.body), dep, found;
  var list;
  if(doc === null) {
    throw({forbidden: 'No demand'});
  } else {
    list = [];
    if(doc.depends_on && doc.depends_on.value)
      for(var dep in doc.depends_on.value) {
        list[dep] = doc.depends_on.value[dep];
        if(form.depends_on == list[dep]) {
          found = dep;
          break;
        }
      }
    if(form.action == 'add' && found === undefined)
      list.push(form.depends_on);
    else if(form.action == 'remove' && found !== undefined)
      list.splice(found, 1);
    saveNewVersion(doc, req, 'depends_on', list, new Date().toISOString());
    return ([doc, 'ok']);
  }
};

exports.test2 = function(doc, req) {
  log(req);
  //throw({forbidden: JSON.stringify(req)});
  req.form.type = "payement";
  req.form._id = req.uuid;
  return([req.form, 'cmd=_notify-validate&' + req.body]);
}

exports.newDemand = function(doc, req) {
  var date = new Date().toISOString();
  var  attr,
    //base64 = require('base64'),
    form = JSON.parse(req.body);
  if(doc !== null){
    throw({forbidden: 'New demand only'});
  } else {
    form.type = 'demand';
    form.created_at = date;
    /*if(!form.id) {
      throw({forbidden: 'Missing id'});
    }
    for(attr in form){
      if(attr == 'rev' || attr == 'id')
        continue;
      newTicket =
    }
    for(attr in form.rev) {
      saveNewVersion(attr, form.rev[attr]);
    }
    form.type = 'ticket';
    form._id = form.type + '-' + form.id;
    form.created_at = new Date().toISOString();
    delete form.rev;*/
    return ([form, JSON.stringify(form)]);
  }
}

exports.demand_old = function(doc, req) {
  var date = new Date().toISOString();
  function savePreviousVersion(label) {
    if(!doc[label])
      return
    if(!doc._attachments) {
      doc._attachments = {};
      doc.lastVersion = 0;
    }
    doc.lastVersion += 1;
    if(!doc[label].hasOwnProperty('value')) {
      doc[label] = {value: doc[label],
        author: doc.author || 'unknown',
        date: doc.created_at};
    }
    //var name = 'version_' + doc.lastVersion;
    var name = doc[label].date + "©" + doc[label].author + "©" + label;
    doc._attachments[name] = {
      content_type: 'text/json',
      data: base64.encode(JSON.stringify(doc[label].value))
    };
  }
  function saveNewVersion(label, value) {
    var name;
    var previousValue = doc[label] ? doc[label].value : null;
    doc[label] = {author: req.userCtx.name, date: date, value: value};
    doc.last_edit = date;
    if(!doc._attachments) {
      doc._attachments = {};
      doc.lastVersion = 0;
    }
    doc.lastVersion += 1;
    name = doc[label].date + "©" + doc[label].author + "©" + label;
    doc._attachments[name] = {
      content_type: 'text/json',
      data: base64.encode(JSON.stringify([doc[label].value, previousValue]))
    };
  }
  var  attr,
    base64 = require('base64'),
    form = JSON.parse(req.body);
  if(doc === null){
    if(!form.id) {
      throw({forbidden: 'Missing id'});
    }
    for(attr in form){
      if(attr == 'rev' || attr == 'id')
        continue;
      saveNewVersion(attr, form[attr]);
    }
    for(attr in form.rev) {
      saveNewVersion(attr, form.rev[attr]);
    }
    form.type = 'ticket';
    form._id = form.type + '-' + form.id;
    form.created_at = new Date().toISOString();
    delete form.rev;
    return ([form, JSON.stringify(form)]);
  } else {
    var changes = form;
    delete changes._id;
    for(attr in changes) {
      if(attr == 'rev' || attr == '_id') {
        continue;
      }
      //savePreviousVersion(attr);
      saveNewVersion(attr, form[attr]);
    }
    for(attr in form.rev) {
      //savePreviousVersion(attr);
      saveNewVersion(attr, form.rev[attr]);
    }
    return([doc, JSON.stringify(changes)]);
  }
}

exports.comment = function(doc, req) {
  var form = JSON.parse(req.body);
  if(doc === null) {
    form.type = 'ticket_comment';
    form.user = req.userCtx.name;
    form.created_at = new Date().toISOString();
    form._id = req.uuid;
    return [form, 'ok'];
  } else {
  }
}
