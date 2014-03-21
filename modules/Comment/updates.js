exports.comment_create = function(doc, req) {
  var form = JSON.parse(req.body);
  if(doc === null) {
    form._id        = req.uuid;
    form.type       = 'comment';
    form.author     = req.userCtx.name;
    form.created_at = new Date().getTime();
    form.votes      = {};
    return [form, 'ok'];
  }
  throw({forbidden: 'Doc must not be null'});
}

exports.comment_vote_up = function(doc, req) {
  if(doc != null) {
    doc.votes[req.userCtx.name] = true;
    return [doc, 'ok'];
  }
  throw({forbidden: 'Doc must not be null'});
}

exports.comment_vote_down = function(doc, req) {
  if(doc != null) {
    doc.votes[req.userCtx.name] = false;
    return [doc, 'ok'];
  }
  throw({forbidden: 'Doc must not be null'});
}

