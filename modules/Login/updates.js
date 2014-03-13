exports.user_create = function(doc, req) {
  var form = JSON.parse(req.body)
  if(doc === null) {
    doc = {
      _id:              'user-' + form.name,
      id:               form.name,
      name:             form.name,
      type:             'user',
      email_validated:  false,
      email:            form.email,
      created_at:       new Date().getTime(),
    };
    return [doc, 'ok'];
  }
}

exports.user_field = function (doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    if (!form.hasOwnProperty('element') ||
        !form.hasOwnProperty('value')
    ) {
      throw({forbidden: 'Request incomplete'});
    }
    doc[form.element] = form.value;

    return [doc, 'ok'];
  }
  throw({forbidden: 'Not for user creation'});
}


exports.email_validation = function (doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    if (!form.hasOwnProperty('token')) {
      throw({forbidden: 'Request incomplete'});
    }
    doc.email_validation_token = form.token;
    doc.email_validated = true;

    return [doc, 'ok'];
  }
  throw({forbidden: 'Not for user creation'});
}
