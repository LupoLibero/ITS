var cradle = require('cradle');

var db = new(cradle.Connection)('http://localhost', 5984, {
      cache: true,
      raw: false,
      forceSave: true
  }).database('lupolibero');


var feed = db.changes({ since: 503});

var monitoredTypes = {
  demand: {
    name: 'demand',
    key: '_id',
    templates: {
      subject: 'hello {{subscriber}}',
      message_txt: 'This is a test',
      message_html: '<h1>This is a test</h1>'
    }
  }
};

var isMonitoredType = function (type) {
  return type in monitoredTypes
};

var isNewDoc = function (change) {
  return parseInt(change.changes[0].rev) == 1
}

var getDocWatcherList = function (type, change, callback) {
  var doc = {_id: change.id}
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
      }
      else {
        res.forEach(function (row) {
          console.log(row);
          callback(type, doc, row);
        });
      }
    }
  );
}

var applyTemplates = function (notification, templates, data) {
  function applyOneTemplate (notification, templateName, template, data) {
    notification[templateName] = template.replace(/\{\{(.*)\}\}/, function (match, p1) {
      console.log("match:", p1);
      return data[p1];
    })
  }
  for(var tmpl in templates) {
    applyOneTemplate(notification, tmpl, templates[tmpl], data);
  }
}

var createNotificationDoc = function (type, doc, data) {
  var notification = {
    type: 'notification',
    doc_type: type.name,
    subscriber: data.subscriber,
    created_at: new Date().getTime(),
    displayed: false,
  };
  applyTemplates(notification, type.templates, data);
  console.log("notification", notification);
  db.save(notification, function (err, res) {
    if (err) {
      console.log(err)
    }
    else {
      console.log(res)
    }
  })
}


feed.on('change', function (change) {
  if (change.id.indexOf('-')) {
    var type = monitoredTypes[change.id.split('-')[0]];
    if (type) {
      //console.log(type, change);
      if (isNewDoc(change)) {
        //informNewDocWatchers()
      } else {
        getDocWatcherList(type, change, createNotificationDoc);//.informThem();
      }
    }
  }
});
