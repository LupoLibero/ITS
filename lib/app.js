module.exports = {
  rewrites: require('./rewrites'),
  views: require('./views'),
  updates: require('./updates'),
  types: require('./types'),
  validate_doc_update: require('./validate').validate_doc_update,
  language: "javascript",
  filters: {
    demands: function (doc, req) {
      var types = {demand: null, demand_list: null, vote: null, cost_estimate: null}
      if (doc.type in types) {
        return true;
      }
      return false;
    }
  }
};
