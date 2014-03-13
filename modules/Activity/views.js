exports.activity_all = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        act['_id'] = doc._id;
        emit([doc._id, act.date], act);
      }
    }
  }
}

exports.activity_by_field = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        emit([doc._id, act.element, act.date], act);
      }
    }
  }
}

exports.activity_by_user = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        act = doc.activity[k];
        emit([act.author, act.date], [doc._id, act]);
      }
    }
  }
}

