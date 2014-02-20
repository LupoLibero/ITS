exports.user_list = {
  map: function(doc) {
    if(doc.type && doc.type == 'user' && doc.id){
      emit(doc.id, doc);
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


exports.ticket_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'ticket'){
      if(doc.project_id && doc.id) {
        var votes = {};
        for(var i=0 ; i<doc.votes.length; i++){
          votes[doc.votes] = true;
        }
        emit([doc.project_id, doc.votes.length], {
          project_id: doc.project_id,
          id: doc.id,
          //component: doc.component.value,
          category: doc.category,
          status: doc.status,
          title: doc.title,
          votes: votes,
          rank: doc.votes.length,
        });
      }
    }
  }
};


exports.ticket_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'ticket_vote') {
        if(doc.ticket_id && doc.user_id){
          emit(doc.ticket_id, 1);
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

exports.comments = {
  map: function(doc) {
    if(doc.type == 'ticket_comment') {
      emit([doc.ticket_id, doc.created_at], doc);
    }
  },
}


exports.ticket_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "ticket" && doc.project_id && doc.id){
      var splitId = doc.id.split('#');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
};
