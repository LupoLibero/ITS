var fields = require('couchtypes/fields');

exports.idField = function(idRegExp) {
  var idValidation = function(doc, value) {
    if(doc.hasOwnProperty('_deleted') && doc._deleted === true) {
      return true;
    }
    var mustBe = RegExp(idRegExp.source.replace(/<([a-z_]*)>/g, function (match, p1) {
        return doc[p1];
      }
    ));
    if (!mustBe.test(value)) {
      throw new Error('Incorrect id; value: '+value+' must be: '+mustBe);
    }
  }
  var _idValidation = function (doc, value) {
    if (doc._id != doc.type + ":" + value) {
      throw Error('_id not corresponding to id: '+doc._id+' != '+doc.type+':'+doc.id)
    }
  }
  return fields.string({validators: [idValidation, _idValidation]});
}
