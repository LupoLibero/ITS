exports.user_all = {
  map: function(doc, req) {
    emit(doc.name, doc);
  }
}

exports.user_email = {
  map: function(doc, req) {
    sponsor = false;
    for(i in doc.roles) {
      if(roles[i] === 'sponsor'){
        sponsor = true;
      }
    }
    emit([doc.email, sponsor], doc);
  }
}
