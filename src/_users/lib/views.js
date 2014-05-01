exports.user_all = {
  map: function(doc, req) {
    emit(doc.name, doc);
  }
}
