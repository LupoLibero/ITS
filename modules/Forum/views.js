
exports.forum_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'forum') {
      emit(null, {
        id: doc.id,
        name: doc.name,
      });
    }
  }
};

exports.forum_message_all = {
  map: function(doc) {
    if(doc.type == 'forum') {
      emit([doc.thread_id, doc.created_at], doc);
    }
  },
};
