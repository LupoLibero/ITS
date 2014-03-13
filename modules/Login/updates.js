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
