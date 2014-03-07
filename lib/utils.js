exports.assert = function (assertion, message) {
  if(assertion === false)
    throw new Error(message || 'unauth');
}

exports.unchanged = function (newDoc, oldDoc, field, message) {
  if (oldDoc && oldDoc[field] !== undefined
      && toJSON(oldDoc[field]) != toJSON(newDoc[field])
      && !isDbAdmin())
    throw new Error(message || 'changed_' + field);
}
