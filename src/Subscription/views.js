exports.subscription_by_object_key = {
  map: function(doc) {
    if (doc.type && doc.type === 'subscription') {
      emit([doc.object_key, doc.subscriber], doc);
    }
  }
}
