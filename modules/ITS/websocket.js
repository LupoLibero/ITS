var io     = require('socket.io').listen(8800);
var Q      = require('q');
var cradle = require('cradle');
var db     = new(cradle.Connection)('http://127.0.0.1', 5984, { cache: false }).database('lupolibero');

io.sockets.on('connection', function(socket){
  var project  = '';
  var lang     = '';
  var username = '';

  socket.on('setUsername', function(data){
    username = data;
  });

  socket.on('setProject', function(data){
    project = data;
  });

  socket.on('setLang', function(data){
    lang = data;

    getCards(project).then(function(cards){
      cards.forEach(function(card){

        getCard(card, lang).done(function(card){
          socket.emit('addCard', card);
        });

        // getWorkflow(card.id).then(function(workflow){
        //   console.log(workflow);
        // });

        // getVote('card:'+card.id, username).then(function(){
        //   socket.emit('setVote', card.id);
        // });

        // getRank('card:'+card.id).then(function(rank){
        //   console.log(rank);
        //   socket.emit('setRank', {
        //     id:   card.id,
        //     rank: rank,
        //   });
        // });

      });
    });

  });

  socket.on('saveCard', function(data){
    console.log(data);
  });

});


function getCards(project, lang) {
  defer = Q.defer();
  db.view('its/card_all', function(err, response){
    if(err) defer.reject(err);
    defer.resolve(response);
  });
  return defer.promise;
};

function getCard(card, lang) {
  var defer = Q.defer();
  card.num = card.id.split('.')[1];
  if(card.title.hasOwnProperty(lang)){
    card.title = card.title[lang];
    card.lang  = lang;
  } else {
    card.title = card.title[card.init_lang];
    card.lang  = card.init_lang;
  }
  defer.resolve(card);
  return defer.promise;
}

function getVote(id, username) {
  defer = Q.defer();
  db.view('its/vote_by_user', {
    key: username,
  }, function(err, data) {
    if(err) defer.reject(err);
    if(data.length !== 0 && data[0].value.hasOwnProperty(id)){
      defer.resolve();
    } else {
      defer.reject();
    }
  });
  return defer.promise;
};

function getWorkflow(id) {
  defer = Q.defer();
  db.view('its/card_workflow', {
    key: id,
  }, function(err, data) {
    if(err) defer.reject(err);
    if(data.length !== 0){
      defer.resolve(data[0].value);
    } else {
      defer.reject();
    }
  });
  return defer.promise;
};

function getRank(id) {
  defer = Q.defer();
  db.view('its/vote_by_doc_id', {
    key:    id,
    reduce: true,
  }, function (err, res) {
    if(err) defer.reject(err);
    if(res.length !== 0 && res[0].value.hasOwnProperty(id)) {
      defer.resolve(res[0].value[id]);
    } else {
      console.log('no rank', id);
      defer.resolve(0);
    }
  });
  return defer.promise;
};
