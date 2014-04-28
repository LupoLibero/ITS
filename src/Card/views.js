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
    if (doc.type && doc.type == 'card') {
      emit([doc.project_id, doc.id], {
        id:          doc.id,
        _rev:        doc._rev,
        title:       doc.title,
        init_lang:   doc.init_lang,
        type:        doc.type,
        author:      doc.author,
        created_at:  doc.created_at,
        description: doc.description,
        avail_langs: Object.keys(doc.title),
      });
    }
  }
};
