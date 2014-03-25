var cradle = require('cradle');
var nodemailer = require('nodemailer');
var Q = require('q');
var db, dbView, smtpTransport, sendMail;



function getConfig () {
  var deferred = Q.defer();
  require('properties').parse('modules/Mailer/mailer.conf',
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

      dbView = Q.nbind(db.view, db);

      smtpTransport = nodemailer.createTransport("SMTP", {
        host: config.smtp.host,
        secureConnection: true, // use SSL
          port: config.smtp.port, // port for secure SMTP
          auth: {
              user: config.smtp.user,
              pass: config.smtp.password
          }
      })

      sendMail = Q.nbind(smtpTransport.sendMail, smtpTransport);
      deferred.resolve();
    }
  );
  return deferred.promise;
}

var setEmailOfSubscriber = function (emailObj, username) {
  var deferred = Q.defer();
  db.view(
    'its/user_email',
    {key: username},
    function (err, res) {
      if (err) {
        console.log('err', err);
        deferred.reject(err);
      }
      else {
        if (!res.length) {
          console.log("no email for user", username);
        }
        res.forEach(function (row) {
          emailObj.to = row;
          console.log(emailObj);
          deferred.resolve(emailObj);
        });
      }
    }
  );
  return deferred.promise;
}

var setNotificationAsDisplayed = function (docId) {
  var deferred = Q.defer();
  db.merge(docId, {email_sent: true}, function (err, res) {
    console.log(err, res);
    if (err) {
      deferred.reject(err);
    }
    else {
      deferred.resolve(res);
    }
  });
  return deferred.promise;
}

var sendNotification = function (notification) {
  var emailObj = {
    from: "Test ✔ <test@sylvainduchesne.com>",
    subject: notification.subject,
    text: notification.message_txt,
    html: notification.message_html,
  };
  return setEmailOfSubscriber(emailObj, notification.subscriber)
    .then(sendMail)
    .done(setNotificationAsDisplayed, function (error) {
      console.log(error);
    });
}

function loopBody () {
  db.view(
    'its/notification_all',
    {
      startkey: [false, null],
      endkey: [false, {}]
    },
    function(err, res) {
      if (err) {
        console.log(err)
      }
      else {
        res.forEach(function (row) {
          console.log(row.type, row.subscriber);
          sendNotification(row);
        });
      }
    }
  );
}

function main () {
  setInterval(loopBody,
    1000 * 60 * 5
  );
  loopBody();
}


getConfig().done(main);




//smtpTransport.close()
