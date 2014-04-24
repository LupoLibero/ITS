var cradle = require('cradle');
var _      = require('underscore');
var Q      = require('q');
var crypto = require('crypto');
var db, feed;

function getConfig () {
  var deferred = Q.defer();
  require('properties').parse('modules/Notification/notification_creator.conf',
    {path: true, sections: true},
    function(error, config) {
      if (error) {
        console.error (error);
        return deferred.reject(error);
      }

      db = new(cradle.Connection)(config.db.base_url, config.db.port, {
        cache: true,
        raw: false,
        forceSave: true,
        auth: { username: config.db.user, password: config.db.password }
      }).database(config.db.name);

      feed = db.changes(/*{ since: 42}*/);
      deferred.resolve();
    }
  );
  return deferred.promise;
}


var helpers = {
  buildValidationUrl: function(notification, type, data) {
    var deferred = Q.defer();
    console.log("buildValidationUrl");
    crypto.randomBytes(10, function(ex, buf) {
      var token = buf.toString('hex');
      shasum = crypto.createHash('md5')
      shasum.update(token);
      var token_md5 = shasum.digest('hex');
      console.log(token, token_md5)
      data.validationUrl = 'http://localhost:5984/lupolibero/_design/its/_rewrite/#email_validation?token=' + token;
      db.merge('user-' + data.subscriber,
        {email_validation_token: token_md5},
        function (err, res) {
          console.log(err, res);
        }
      );
      deferred.resolve();
    });
    return deferred.promise;
  },
}

var monitoredTypes = {
  demand: {
    name: 'demand',
    key: '_id',
    templates: {
      subject: 'hello {{subscriber}}',
      message_txt: 'This is a test',
      message_html: '<h1>This is a test</h1>'
    },
    notification_type: 'email',
    monitoring_type: 'user'
  },
  user: {
    name: 'user',
    key: '_id',
    preprocessors: ['buildValidationUrl'],
    templates: {
      subject: 'Email validation {{subscriber}}',
      message_text: 'Validation url: {{validationUrl}}',
      message_html: '<p>Validation url: <a href="{{validationUrl}}">{{validationUrl}}</a>'
    },
    notification_type: 'email',
    monitoring_type: 'to-user',
  }
};



var isMonitoredType = function (type) {
  return type in monitoredTypes
};

var isDocCreation = function (change) {
  return parseInt(change.changes[0].rev) == 1
}

var getDocWatcherList = function (type, change) {
  var doc = {_id: change.id};
  var deferred = Q.defer();
  if (type.key != '_id') {
    console.log('getFullDoc')
    // getDoc
  }
  console.log('call view', doc[type.key]);
  db.view(
    'its/subscription_by_object_key',
    {
      key: doc[type.key]
    },
    function(err, res) {
      if (err) {
        console.log(err)
        deferred.reject(err)
      }
      else {
        res.forEach(function (row) {
          row._seq = change.seq;
          row._id = change.id;
          console.log(row);
          //callback(type, doc, row);
          // TODO: does not loop
          deferred.resolve(row);
        });
      }
    }
  );
  return deferred.promise;
}

var initNotification = function (data, type) {
  var deferred = Q.defer();
  deferred.resolve({
    _id: 'notification-' + data._seq + '-' + data.subscriber,
    type: 'notification',
    doc_type: type.name,
    doc_id: data._id,
    subscriber: data.subscriber,
    created_at: new Date().getTime(),
    displayed: false,
    notification_type: type.notification_type || "",
  });
  return deferred.promise;
}

var applyPreprocessors = function (notification, type, data) {
    var promises = [], deferred;
  _.forEach(type.preprocessors, function (prepro) {
    promises.push(helpers[prepro](notification, type, data));
  });
  return Q.all(promises).thenResolve(notification);
}

var applyAllTemplates = function (notification, type, data) {

  function applyOneTemplate (notification, templateName, template, data) {
    notification[templateName] = template.replace(/\{\{([^\{]+)\}\}/g, function (match, p1) {
      console.log("match:", p1);
      return data[p1];
    })
  }
  for(var tmpl in type.templates) {
    applyOneTemplate(notification, tmpl, type.templates[tmpl], data);
  }
  return notification;
}

var saveNotification = function (notification) {
  var deferred = Q.defer();
  console.log("notification", notification);
  db.save(notification, function (err, res) {
    if (err) {
      console.log(err);
      deferred.reject(err);
    }
    else {
      console.log(res);
      deferred.resolve(res);
    }
  });
  return deferred.promise;
}

var createNotificationDocAndSave = function (type, data) {

  var applyPreprocessorsCaller = function (notification) {
    return applyPreprocessors(notification, type, data)
  }
  var applyAllTemplatesCaller = function (notification) {
    return applyAllTemplates(notification, type, data);
  }

  return initNotification(data, type).
    then(applyPreprocessorsCaller).
    then(applyAllTemplatesCaller).
    done(saveNotification);
}


function main () {
  feed.on('change', function (change) {
    if (change.id.indexOf('-')) {
      var _idArray = change.id.split('-')
      var type = monitoredTypes[_idArray[0]];
      var createNotificationDocAndSaveCaller = function (data) {
        return createNotificationDocAndSave(type, data)
      }

      if (type) {
        console.log("\n\n", _idArray, change.seq);
        console.log(change);
        if (type.monitoring_type == 'to-user') {
          if (isDocCreation(change)) {
            console.log("newDoc")
            //informNewDocWatchers()
            createNotificationDocAndSave(type, {
              subscriber: _idArray[1],
              _seq: change.seq,
              _id: change.id
            });
          }
        }
        else {
          if (isDocCreation(change)) {
            console.log("newDoc")
            //informNewDocWatchers()
          } else {
            getDocWatcherList(type, change).
              done(createNotificationDocAndSaveCaller);
          }
        }
      }
    }
  });
}

getConfig().done(main);
