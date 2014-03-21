exports.user_get = {
  map: function(doc) {
    if(doc.type && doc.type == 'user' && doc.id){
      emit(doc.id, doc);
    }
  }
}

exports.user_email = {
  map: function(doc) {
    if(doc.type && doc.type == 'user' && doc.email){
      emit(doc.id, doc.email);
    }
  }
}
