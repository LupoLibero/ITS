exports.comment_all = {
  map: function(doc) {
    if(doc.type == 'comment') {
      emit([doc.parent_id, doc.created_at], doc);
    }
  },
}
