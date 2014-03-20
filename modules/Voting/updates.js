exports.vote_create = function(doc, req) {
  var form = JSON.parse(req.body);
  if(doc === null) {
    author = req.userCtx.name;
    _id    = form.object_id;

    if(typeof author != 'string'){
      throw({forbidden: 'Can\'t vote if you are not connect'});
    }

    doc = {};
    doc.type         = 'vote';
    doc.voter        = author;
    doc.vote         = true;
    doc.id           = _id+'--'+author;
    doc.voted_doc_id = _id;
    doc._id          = doc.type +'--'+ doc.id;

    return [doc, 'ok'];
  }
}

exports.vote_delete = function(doc, req) {
  if(doc !== null) {
    return [{
      _id:      doc._id,
      _rev:     doc._rev,
      _deleted: true,
    }, 'ok'];
  }
  throw({forbidden: 'Vote doesn\'t exist'});
}
