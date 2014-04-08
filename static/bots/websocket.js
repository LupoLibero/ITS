var Q, cradle, db, getCard, getCards, getVote, getWorkflow, io, view;

io = require('socket.io').listen(8800);

Q = require('q');

cradle = require('cradle');

db = new cradle.Connection('http://127.0.0.1', 5984, {
  cache: false
}).database('lupolibero');

view = Q.nbind(db.view, db);

getCards = function(project) {
  return view('its/card_all');
};

getCard = function(card, lang, username) {
  var defer;
  defer = Q.defer();
  card.num = card.id.split('.')[1];
  if (card.title.hasOwnProperty(lang)) {
    card.title = card.title[lang];
    card.lang = lang;
  } else {
    card.title = card.title[card.init_lang];
    card.lang = card.init_lang;
  }
  defer.resolve([card, lang, username]);
  return defer.promise;
};

getVote = function(result) {
  var card, defer, lang, username;
  card = result[0];
  lang = result[1];
  username = result[2];
  defer = Q.defer();
  view('its/vote_all', {
    key: "card:" + card.id
  }).then(function(data) {
    var row, user, vote, _i, _len, _ref;
    result = {};
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      row = data[_i];
      _ref = row.value;
      for (user in _ref) {
        vote = _ref[user];
        result[user] = vote;
      }
    }
    card.rank = Object.keys(result).length;
    card.vote = {};
    if (result.hasOwnProperty(username)) {
      card.hasVote = true;
      card.vote[username] = result[username];
    }
    if (result.hasOwnProperty(username)) {
      card.hasVote = true;
      card.vote[username] = result[username];
    } else {
      card.hasVote = false;
    }
    return defer.resolve([card, lang, username]);
  }, function(err) {
    return defer.reject(err);
  });
  return defer.promise;
};

getWorkflow = function(result) {
  var card, defer, lang, username;
  card = result[0];
  lang = result[1];
  username = result[2];
  defer = Q.defer();
  view('its/card_workflow', {
    key: card.id
  }).then(function(data) {
    data = data[0].value;
    if (data.cards.hasOwnProperty(card.id)) {
      card.list_id = data.cards[card.id].list_id;
      card.tag_list = data.cards[card.id].tag_list;
    } else {
      card.list_id = "ideas";
      card.list_id = [];
    }
    if (data.cost_estimate && data.cost_estimate.hasOwnProperty(card.id)) {
      card.cost_estimate = data.cost_estimate[card.id];
    } else {
      card.cost_estimate = null;
    }
    if (data.payment && data.payment.hasOwnProperty(card.id)) {
      card.payment = data.payment[card.id];
    } else {
      card.payment = null;
    }
    return defer.resolve([card, lang, username]);
  }, function(err) {
    return defer.reject(err);
  });
  return defer.promise;
};

io.sockets.on('connection', function(socket) {
  var lang, project, username;
  project = '';
  lang = '';
  username = '';
  socket.on('setUsername', function(data) {
    return username = data;
  });
  socket.on('setProject', function(data) {
    return project = data;
  });
  socket.on('setLang', function(data) {
    return lang = data;
  });
  return socket.on('getAll', function(data) {
    return getCards(project).then(function(cards) {
      return cards.forEach(function(card) {
        return getCard(card, lang, username).then(getVote).then(getWorkflow).then(function(card) {
          return socket.emit('addCard', card[0]);
        }, function(err) {
          return console.log(err);
        });
      });
    });
  });
});
