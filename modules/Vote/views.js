exports.vote_by_doc_id = {
  map: function (doc) {
    if (doc.type && doc.type == 'vote') {
      var obj = {}
      obj[doc.voted_doc_id] = doc.vote
      emit(doc.voted_doc_id, obj);
    }
  },
  reduce: function (keys, values, rereduce) {
    var ranks = {} ,idx;

    for (idx = 0 ; idx < values.length ; idx++) {
      for (voted_doc_id in values[idx]) {
        ranks[voted_doc_id] = (ranks[voted_doc_id] || 0) + (values[idx][voted_doc_id] ? 1 : -1);
      }
    }
    return ranks;
  }
}


exports.vote_by_user = {
  map: function (doc) {
    if (doc.type && doc.type == 'vote') {
      var obj = {}
      obj[doc.voted_doc_id] = doc.vote
      emit(doc.voter, obj);
    }
  },
}
