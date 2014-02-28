exports.types = {
  project: {
    permissions: {
      add: ['hadRole', '_admin'],
      update: ['hadRole', '_admin'],
      remove: ['hadRole', '_admin']
    },
    fields: {
      id: 'string',
      name: 'string',
      prefix: 'string'
    }
  },
  comment: {
    permissions: {
      add: 'loggedIn',
      update: 'loggedIn',
      remove: [['usernameMatchesField', 'author'],
               ['hasRole', '_admin']],
    },
    fields: {
      author: 'creator',
      created_at: 'createdTime',
      parent_id: ['string', {
        permissions: {
          update: 'fieldUneditable'
        }
      }],
      message: ['string', {
      }]
    }
  }
}

// Project
exports.project_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'project' && doc.id) {
      emit(null, {
        id: doc.id,
        name: doc.name,
      });
    }
  }
};

// User
exports.user_get = {
  map: function(doc) {
    if(doc.type && doc.type == 'user' && doc.id){
      emit(doc.id, doc);
    }
  }
};

exports.config = {
  map: function(doc){
    if(doc._id == 'config'){
      emit('categories', doc.categories);
      emit('statuses', doc.statuses);
    }
  }
};

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
            rank: rank,
          },
          {title: true}
        );
      }
    }
  }
};


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
};



exports.comment_all = {
  map: function(doc) {
    if(doc.type == 'comment') {
      emit([doc.parent_id, doc.created_at], doc);
    }
  },
};


exports.demand_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "demand" && doc.project_id && doc.id){
      var splitId = doc.id.split('#');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
};

exports.activity_all = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        emit([doc._id, act[2]], act);
      }
    }
  }
};

exports.activity_by_field = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        emit([doc._id, act[0], act[2]], act);
      }
    }
  }
};

exports.activity_by_user = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        emit([act[1], act[2]], [doc._id, act]);
      }
    }
  }
};
