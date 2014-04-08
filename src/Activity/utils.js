var _ = require('underscore')._;

exports.updateActivity = function (doc, req, element, _rev) {
  if (!doc.hasOwnProperty('activity')) {
    doc.activity = [];
  }
  doc.activity.push({
    element: element,
    author:  req.userCtx.name,
    date:    doc.updated_at,
    _rev:    doc._rev,
    content: _.clone(doc[element])
  });
  // this will result as a conflict if user had not last revision
  // must be handled client side
  // not needed in every case
  if (_rev) {
    doc._rev = _rev;
  }
}
