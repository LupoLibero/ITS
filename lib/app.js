module.exports = {
  rewrites: require('./rewrites'),
  views: require('./views'),
  updates: require('./updates'),
  types: require('./types'),
  validate_doc_update: require('./validate').validate_doc_update,
  language: "javascript",
  filters: {
    cards: function (doc, req) {
      var types = {card: null, card_list: null, vote: null, cost_estimate: null, payment: null}
      if (doc.type in types) {
        return true;
      }
      return false;
    }
  }
};
