var _ = require('underscore')._;

exports.updateActivity = function (doc, author, element) {
  if (!doc.hasOwnProperty('activity')) {
    doc.activity = [];
  }

  doc.activity.push({
    author:  author,
    _rev:    doc._rev,
    element: element,
    date:    doc.updated_at,
    content:  _.clone(doc[element]),
  });
}
