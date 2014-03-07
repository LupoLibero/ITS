
exports.user_get = {
  map: function(doc) {
    if(doc.type && doc.type == 'user' && doc.id){
      emit(doc.id, doc);
    }
  }
}

