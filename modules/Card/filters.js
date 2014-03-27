exports.notifications = function (doc, req) {
  var types = {
    card: null,
    card_list: null,
    vote: null,
    cost_estimate: null,
    payment: null
  }
  return doc.type in types;
};

