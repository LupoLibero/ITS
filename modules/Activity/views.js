exports.activity_all = {
  map: function(doc) {
    var k, act;
    if (doc.hasOwnProperty('activity')) {
      for(k in doc.activity) {
        activity = doc.activity[k];
        act = {
          _id:      doc._id,
          element:  activity.element,
          author:   activity.author,
          date:     activity.date,
          _rev:     activity._rev,
          content:  activity.content,
        };
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

