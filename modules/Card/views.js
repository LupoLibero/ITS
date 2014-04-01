exports.card_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    var rank, list_id;

    if (doc.type) {
      switch(doc.type) {
        case 'card':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag, doc.id],
            {
              project_id:  doc.project_id,
              id:          doc.id,
              _rev:        doc._rev,
              title:       doc.title,
              init_lang:   doc.init_lang,
              type:        doc.type,
              list_id:     doc.list_id,
              tag_list:    doc.tag_list,
            },
            {title: true}
          );
          break;
        case 'cost_estimate':
          emit([doc.project_id, 'default', doc.card_id], doc);
          break;
        case 'payment':
          emit([doc.project_id, 'default', doc.card_id], doc);
          break;
        case 'vote':
          if (doc.voted_doc_id.split(':')[0] == 'card') {
            (function() {
              var cardId = doc.voted_doc_id.split(':')[1];
              emit(
                [
                  cardId.split('.')[0],
                  "default",
                  cardId
                ],
                {
                  voter: doc.voter,
                  vote: doc.vote,
                  card_id: cardId,
                  type: doc.type
              });
            })();
          }
          break;
      }
    }
  }
};

exports.card_get = {
  map: function(doc) {
    var change;
    var translation = require('views/lib/translation').translation();
    if (doc.type) {
      switch(doc.type) {
        case 'card':
          translation.emitTranslatedDoc(
            [doc.id, translation._keyTag],
            {
              _rev:         doc._rev,
              _id:          doc._id,
              id:           doc.id,
              description:  doc.description,
              created_at:   doc.created_at,
              updated_at:   doc.updated_at,
              init_lang:    doc.init_lang,
            },
            {description:true}
          );
          for (change in doc.activity) {
            emit([doc.id, 'default', doc.activity[change].date], {activity: [doc.activity[change]]})
          }
          break;
        case 'comment':
          emit([doc.parent_id.split(':')[1], 'default', doc.created_at], {activity: [doc]});
          break;
      }
    }
  }
}

exports.card_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "card" && doc.project_id && doc.id){
      var splitId = doc.id.split('.');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
}

exports.card_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'card_vote') {
        if(doc.card_id && doc.user_id){
          emit(doc.card_id, 1);
        }
      }
    }
  },
  reduce: "_sum"
}

