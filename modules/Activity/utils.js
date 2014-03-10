var _ = require('underscore')._;

exports.updateActivity = function (doc, req, element, _rev) {
  if (!doc.hasOwnProperty('activity')) {
    doc.activity = [];
  }
  doc.activity.push([
    element,
    req.userCtx.name,
    doc.updated_at,
    doc._rev,
    _.clone(doc[element])
  ]);
  // this will result as a conflict if user had not last revision
  // must be handled client side
  // not needed in every case
  if (_rev) {
    doc._rev = _rev;
  }
}
