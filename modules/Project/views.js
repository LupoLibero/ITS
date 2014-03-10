exports.project_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation;
    if(doc.type && doc.type == 'project'){
      translation.emitTranslatedDoc(
        [doc._id, translation._keyTag],
        {
          _id:          doc._id,
          id:           doc.id,
          name:         doc.name,
          description:  doc.description,
          init_lang:    doc.init_lang,
        },
        {name: true, description: true}
      );
    }
  }
}
