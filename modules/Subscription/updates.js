exports.subscription_create = function(doc, req) {
  var form = JSON.parse(req.body);
  if (doc === null) {
    if (doc.hasOwnProperty('object_key')){
      throw({forbidden: 'Request incomplete'});
    }
    doc = {
      _id:        'subscription--'+form.object_key+'--'+req.userCtx.name,
      subscriber: form.object_key,
      object_key: req.userCtx.name,
      type:       'subscription',
    };
    return [doc, 'ok'];
  }
}
