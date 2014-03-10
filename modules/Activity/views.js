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
}

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
}

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
}

