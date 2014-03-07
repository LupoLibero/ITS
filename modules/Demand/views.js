
exports.demand_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation;
    var rank;
    if(doc.type && doc.type == 'demand'){
      if(doc.project_id && doc.id) {
        rank = Object.keys(doc.votes).length;
        translation.emitTranslatedDoc(
          [doc.project_id, translation._keyTag, rank],
          {
            project_id: doc.project_id,
            id: doc.id,
            category: doc.category,
            status: doc.status,
            title: doc.title,
            votes: doc.votes,
            init_lang: doc.init_lang,
            rank: rank,
          },
          {title: true}
        );
      }
    }
  }
}

exports.demand_get = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation;
    var rank;
    if(doc.type && doc.type == 'demand'){
      if(doc.project_id && doc.id) {
        rank = Object.keys(doc.votes).length;
        translation.emitTranslatedDoc(
          [doc.id, translation._keyTag],
          {
            _rev: doc._rev,
            _id: doc._id,
            project_id: doc.project_id,
            id: doc.id,
            category: doc.category,
            description: doc.description,
            status: doc.status,
            title: doc.title,
            created_at: doc.created_at,
            updated_at: doc.updated_at,
            init_lang: doc.init_lang,
          },
          {title: true, description:true}
        );
      }
    }
  }
}

exports.demand_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "demand" && doc.project_id && doc.id){
      var splitId = doc.id.split('#');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
}

exports.demand_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'demand_vote') {
        if(doc.demand_id && doc.user_id){
          emit(doc.demand_id, 1);
        }
      }
    }
  },
  reduce: "_sum"
}

