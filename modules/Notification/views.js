
exports.subscription_by_object_key = {
  map: function(doc) {
    if(doc.type && doc.type == 'subscription') {
      emit(doc.object_key, {subscriber: doc.subscriber});
    }
  }
};

exports.notification_all = {
  map: function(doc) {
    if(doc.type && doc.type == 'notification') {
      emit([doc.displayed, doc.subscriber], doc);
    }
  }
};
