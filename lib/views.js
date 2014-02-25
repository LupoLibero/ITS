exports.user_list = {
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
      emit('resolutions', doc.resolutions);
    }
  } 
};

exports.lib = {
  recursive_merge: function(dst, src, special_merge){
    var e;
    if(!dst){
      return src
    }
    if(!src){
      return dst
    }
    if(typeof(src) == 'object'){
      for(e in src){
        if(e in special_merge){
          dst[e] = special_merge[e](e, dst, src);
        } else {
          dst[e] = recursive_merge(dst[e], src[e], special_merge)
        }
      }
    }
    return dst;
  }
};


exports.demand_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'demand'){
      if(doc.project_id && doc.id) {
        var rank = Object.keys(doc.votes).length;
        emit([doc.project_id, rank], {
          project_id: doc.project_id,
          id: doc.id,
          _rev: doc._rev,
          category: doc.category,
          status: doc.status,
          title: doc.title,
          votes: doc.votes,
          rank: rank,
        });
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
}


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

exports.comment_all = {
  map: function(doc) {
    if(doc.type == 'comment') {
      emit([doc.parent_id, doc.created_at], doc);
    }
  },
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
};

exports.demand_activity = {
  map: function(doc) {
    var timestamp, act;
    if (doc.type == "demand" && doc.activity) {
      log(doc.activity)
      for(timestamp in doc.activity) {
        act = doc.activity[timestamp];
        emit(timestamp, act);
      }
    }
  }
}

exports.demand_activity_by_field = {
  map: function(doc) {
    var timestamp, act;
    if (doc.type == "demand" && doc.activity) {
      for(timestamp in doc.activity) {
        act = doc.activity[timestamp];
        emit([act[1], timestamp], act);
      }
    }
  }
}

exports.demand_activity_by_user = {
  map: function(doc) {
    var timestamp, act;
    if (doc.type == "demand" && doc.activity) {
      for(timestamp in doc.activity) {
        act = doc.activity[timestamp];
        emit([act[0], timestamp], act);
      }
    }
  }
}
