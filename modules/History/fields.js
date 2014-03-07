var fields = require('couchtypes/fields');
var utils       = require('lib/utils');
var assert      = utils.assert;

exports.activityField = function () {
  var CHANGE_ELEMENT = 0,
      CHANGE_AUTHOR  = 1,
      CHANGE_DATE    = 2,
      PREVIOUS_REV   = 3,
      OLD_CONTENT    = 4;
  return new fields.Field({
    permissions: {
      update: function (newDoc, oldDoc, newValue, oldValue, userCtx) {
        var lastActivity = newValue.pop();

        assert(newValue.length >= 0, "Activity must be saved on update");

        assert(oldValue && _.isEqual(newValue, oldValue),
            "Old activity has been modified")

        assert(newDoc.hasOwnProperty(lastActivity[CHANGE_ELEMENT]) &&
               oldDoc.hasOwnProperty(lastActivity[CHANGE_ELEMENT]),
            "Change on a field that does not exist");

        assert(lastActivity[CHANGE_AUTHOR] == userCtx.name,
            "Change must be done by logged in user");

        assert(!isNaN(lastActivity[CHANGE_DATE]), "3rd element must be a timestamp");

        assert(_.isEqual(lastActivity[OLD_CONTENT], oldDoc[lastActivity[CHANGE_ELEMENT]]),
            "Previous version is not correctly saved");
      },
    },
  })
}
