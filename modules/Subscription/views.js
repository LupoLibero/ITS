exports.subscription_by_object_key = {
  map: function(doc) {
    if (doc.type && doc.type === 'subscription') {
      emit([doc.object_key, doc.subscriber], doc);
    }
  }
}

exports.subscription_short = {
  map: function(doc) {
    if (doc.type && doc.type === 'subscription' && doc.notification_type == 'short' {
      emit([doc.object_key, doc.subscriber], doc);
    }
  }
}
