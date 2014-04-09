exports.vote_create = function(doc, req) {
  var form;
  if(req.body === "") {
    form = req.query;
  } else {
    form = JSON.parse(req.body);
  }
  if(doc === null) {
    var author = req.userCtx.name || form.author;

    var doc = {};
    doc.type         = 'vote';
    doc.voter        = author;
    doc.vote         = true;
    doc.id           = form.element+':'+form.object_id+'-'+author;
    doc.voted_doc_id = form.element+':'+form.object_id;
    doc._id          = doc.type+':'+doc.id;

    return [doc, 'ok'];
  }
}

exports.vote_delete = function(doc, req) {
  if(doc !== null) {
    return [{
      _id:      doc._id,
      _rev:     doc._rev,
      type:     doc.type,
      _deleted: true,
    }, 'ok'];
  }
  throw({forbidden: 'Vote doesn\'t exist'});
}
