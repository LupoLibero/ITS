exports.subscription_create = function(doc, req) {
  var form = JSON.parse(req.body);
  if (doc === null) {
    if (!form.hasOwnProperty('object_key')){
      throw({forbidden: 'Request incomplete'});
    }
    doc = {
      _id:        'subscription:'+form.object_key+'-'+req.userCtx.name,
      object_key: form.object_key,
      subscriber: req.userCtx.name,
      type:       'subscription',
    };
    return [doc, 'ok'];
  }
}

exports.subscription_delete = function(doc, req) {
  var form = JSON.parse(req.body);
  if (doc !== null) {
    return [{
      _id:      doc._id,
      _rev:     doc._rev,
      _deleted:  true,
    }, 'ok'];
  }
}
