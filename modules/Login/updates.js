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
    };
    return [doc, 'ok'];
  }
}
