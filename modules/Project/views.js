
exports.project_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'project' && doc.id) {
      emit(null, {
        id: doc.id,
        name: doc.name,
      });
    }
  }
}
