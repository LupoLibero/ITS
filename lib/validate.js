var couchtypes = require('couchtypes/types');
var types      = require('./types');
var utils      = require('./utils');
var hasRole    = utils.hasRole;


exports.validate_doc_update = function(newDoc, oldDoc, userCtx) {
  utils.assert(newDoc.hasOwnProperty('_id'), 'New doc must have a _id');
  if (!hasRole('_admin')) {
    utils.unchanged('type');
  }
  if (newDoc.hasOwnProperty('id') && newDoc.hasOwnProperty('type')) {
    utils.assert(newDoc._id == newDoc.type + '-' + newDoc.id, '_id must be like "<type>-<id>"');
  }
  utils.unchanged('id');

  couchtypes.validate_doc_update(types, newDoc, oldDoc, userCtx);

};
