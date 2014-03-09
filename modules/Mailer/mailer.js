var cradle = require('cradle');
var nodemailer = require('nodemailer');
var Q = require('q');

var db = new(cradle.Connection)('http://localhost', 5984, {
  cache: true,
  raw: false,
  forceSave: true
}).database('lupolibero');

var dbView = Q.nbind(db.view, db);

var smtpTransport = nodemailer.createTransport("SMTP", {
  host: "ssl0.ovh.net",
  secureConnection: true, // use SSL
    port: 465, // port for secure SMTP
    auth: {
        user: "test@sylvainduchesne.com",
        pass: "suppleteam"
    }
})

var sendMail = Q.nbind(smtpTransport.sendMail, smtpTransport);



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

var setNotificationAsDisplayed = function () {
  console.log("displayed= true")
  return;
}

var sendNotification = function (notification) {
  var emailObj = {
    from: "Fred Foo ✔ <test@sylvainduchesne.com>",
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


//setInterval(function () {
    console.log("toto")
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
            //callback(type, doc, row);
            sendNotification(row);
          });
        }
      }
    );
//  },
//  1000 * 60
//);

//smtpTransport.close()
