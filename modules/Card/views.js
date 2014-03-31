exports.card_workflow = {
  map: function(doc) {
    var obj;
    if (doc.type) {
      obj = {};
      switch(doc.type) {
        case 'card':
          obj[doc.id] = {
            id: doc.id,
            list_id: doc.list_id,
            tag_list: doc.tag_list
          };
          emit(doc.id, {
            cards: obj
          });
          break;
        case 'cost_estimate':
          obj[doc.card_id] = doc.estimate
          emit(doc.card_id, {cost_estimate: obj});
          break;
        case 'payment':
          obj[doc.card_id] = doc.amount
          emit(doc.card_id, {payment: obj});
          break;
      }
    }
  },
  reduce: function (keys, values, rereduce) {
    var idx, id, e, i, cardId, doc;
    var result = {
      cards: {},
      cost_estimate: {},
      payment: {},
    };

    function applyWorkflowRules (card) {
      var listId = card.list_id;

      if (listId != 'doing' && listId != 'done') {
        listId = 'ideas';
        if (card.tag_list.length) {
          listId = 'todo';
          if (result.cost_estimate[card.id]) {
            listId = 'estimated';
            if (result.payment[card.id] &&
                result.payment[card.id] >= result.cost_estimate[card.id]) {
              listId = 'funded';
            }
          }
        }
      }
      card.list_id = listId;
    }

    for(idx = 0 ; idx < values.length ; idx++){
      for (cardId in values[idx].cost_estimate) {
        result.cost_estimate[cardId] = values[idx].cost_estimate[cardId];
      }
      for (cardId in values[idx].payment) {
        result.payment[cardId] = (result.payment[cardId] || 0) + values[idx].payment[cardId];
      }
      for (cardId in values[idx].cards) {
        result.cards[cardId] = values[idx].cards[cardId];
      }
    }
    for (cardId in result.cards) {
      applyWorkflowRules(result.cards[cardId]);
    }
    return result;
  }
};

exports.card_all = {
    map: function(doc) {
    var translation = require('views/lib/translation').translation();
    var rank, list_id;

    if (doc.type) {
      switch(doc.type) {
        case 'card':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag, doc.id],
            {
              project_id: doc.project_id,
              id: doc.id,
              _rev: doc._rev,
              title: doc.title,
              init_lang: doc.init_lang,
              type: doc.type,
              list_id: doc.list_id,
              tag_list: doc.tag_list,
            },
            {title: true}
          );
          break;
        case 'cost_estimate':
          emit([doc.project_id, 'default', doc.card_id], doc);
          break;
        case 'payment':
          emit([doc.project_id, 'default', doc.card_id], doc);
          break;
        case 'vote':
          if (doc.voted_doc_id.split(':')[0] == 'card') {
            (function() {
              var cardId = doc.voted_doc_id.split(':')[1];
              emit(
                [
                  cardId.split('.')[0],
                  "default",
                  cardId
                ],
                {
                  voter: doc.voter,
                  vote: doc.vote,
                  card_id: cardId,
                  type: doc.type
              });
            })();
          }
          break;
      }
    }
  }
};

exports.card_get = {
  map: function(doc) {
    var change;
    var translation = require('views/lib/translation').translation();
    if (doc.type) {
      switch(doc.type) {
        case 'card':
          translation.emitTranslatedDoc(
            [doc.id, translation._keyTag],
            {
              _rev:         doc._rev,
              _id:          doc._id,
              id:           doc.id,
              description:  doc.description,
              created_at:   doc.created_at,
              updated_at:   doc.updated_at,
              init_lang:    doc.init_lang,
            },
            {
              id: false,
              type: false,
              description:true
            }
          );
          for (change in doc.activity) {
            emit([doc.id, 'default', doc.activity[change].date], {activity: [doc.activity[change]]})
          }
          break;
        case 'comment':
          emit([doc.parent_id.split(':')[1], 'default', doc.created_at], {activity: [doc]});
          break;
      }
    }
  }
}

exports.card_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "card" && doc.project_id && doc.id){
      var splitId = doc.id.split('.');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
}

exports.card_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'card_vote') {
        if(doc.card_id && doc.user_id){
          emit(doc.card_id, 1);
        }
      }
    }
  },
  reduce: "_sum"
}

