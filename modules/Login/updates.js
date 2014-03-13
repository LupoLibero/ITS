
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
