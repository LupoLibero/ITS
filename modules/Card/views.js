exports.card_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    var rank, list_id;

    if (doc.type) {
      switch(doc.type) {
        /*case 'card_list':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag],
            {
              id:    doc.id,
              name:  doc.name,
              type:  doc.type,
            },
            {name: true}
          );
          break;*/
        case 'card':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag, doc.id],
            {
              project_id:  doc.project_id,
              _id:         doc._id,
              id:          doc.id,
              title:       doc.title,
              init_lang:   doc.init_lang,
              type:        doc.type,
              list_id:     doc.list_id,
              tag_list:    doc.tag_list,
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
              var cardId = doc.voted_doc_id.split(':')[2];
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
  },
  reduce: function (keys, values, rereduce) {
    recursive_merge = function(dst, src, special_merge){
      var e;
      if(!dst){
        return src
      }
      if(!src){
        return dst
      }
      if(typeof(src) == 'object'){
        for(e in src){
          if(e in special_merge){
            dst[e] = special_merge[e](e, dst, src);
          } else {
            dst[e] = recursive_merge(dst[e], src[e], special_merge)
          }
        }
      }
      return dst;
    }
    var mergeArrayById = function (element, dstParent, srcParent) {
      var newDst = [];
      var dst    = dstParent[element];
      var src    = srcParent[element];
      var alreadyPushed   = {};
      var cardDst, cardSrc, idDst, idSrc;
      //log([dst, "             ", src]);
      for (idDst in dst) {
        cardDst = dst[idDst];
        for (idSrc in src) {
          cardSrc = src[idSrc];
          if (cardDst.id == cardSrc.id) {
            newDst.push(cardSrc);
            alreadyPushed[cardDst.id] = true;
            continue;
          }
        }
        if (!alreadyPushed[cardDst.id]) {
          newDst.push(cardDst);
          alreadyPushed[cardDst.id] = true;
        }
      }
      for (idSrc in src) {
        cardSrc = src[idSrc];
        if (!alreadyPushed[cardSrc.id]) {
          newDst.push(cardSrc);
        }
      }
      return newDst;
    }
    addingMerge = function (element, dstParent, srcParent) {
      return (dstParent[element] || 0) + (srcParent[element] || 0);
    }

    var idx, id, e, i, doc;
    var result = {
      /*lists: [
        {id: 'ideas'},
        {id: 'todo'},
        {id: 'estimated'},
        {id: 'funded'},
        {id: 'doing'},
        {id: 'done'},
      ],*/
      lists: ['ideas', 'todo', 'estimated', 'funded', 'doing', 'done'],
      cards: [],
      cost_estimate: {},
      votes: {},
      payment: {},
      rank: {},
      list_id: {}
    };
    var reverseMapping = {};

    function recalculateRank (docId) {
      result.rank[docId] = Object.keys(result.votes[docId] || {}).length;
    }
    function applyWorkflowRules (docId) {
      var i = reverseMapping[docId];
      var tagList = [];
      var listId;
      if (!isNaN(i)) {
        tagList = result.cards[i].tag_list;
        listId  = result.cards[i].list_id;
      }
      listId = result.list_id[docId] || listId;
      log([docId, listId, tagList, result.cost_estimate[docId]]);
      if (listId != 'doing' && listId != 'done') {
        listId = 'ideas';
        if (tagList.length) {
          listId = 'todo';
          if (result.cost_estimate[docId]) {
            listId = 'estimated';
            if (result.payment[docId] &&
                result.payment[docId] >= result.cost_estimate[docId]) {
              listId = 'funded';
            }
          }
        }
      }
      result.list_id[docId] = listId;
    }

    if (!rereduce) {
      for(idx = 0 ; idx < values.length ; idx++){
        doc = values[idx];
        switch(doc.type) {
          /*case 'card_list':
            for (var id in result.lists) {
              if (doc.id == result.lists[id].id) {
                result.lists[id] = recursive_merge(result.lists[id], doc, {});
              }
            }
            break;*/
          case 'cost_estimate':
            result.cost_estimate[doc.card_id] = doc.estimate;
            break;
          case 'payment':
            result.payment[doc.card_id] = (result.payment[doc.card_id] || 0) + doc.amount;
            break;
          case 'vote':
            result.votes[doc.card_id] = result.votes[doc.card_id] || {};
            result.votes[doc.card_id][doc.voter] = doc.vote;
            break;
          case 'card':
            i = result.cards.push(doc);
            reverseMapping[doc.id] = i - 1;
            result.cost_estimate[doc.id] = result.cost_estimate[doc.id] || 0;
            result.payment[doc.id] = result.payment[doc.id] || 0;
            result.rank[doc.id] = result.rank[doc.id] || 0;
            result.votes[doc.id] = result.votes[doc.id] || {};
            break;
        }
      }
    }
    else {
      for(idx = 0 ; idx < values.length ; idx++){
        result = recursive_merge(result, values[idx],{
          cards: mergeArrayById,
          payment: addingMerge
        });
      }
    }
    log(result.cost_estimate);
    for (idx = 0 ; idx < result.cards.length ; idx++) {
      doc = result.cards[idx]
      log(doc);
      recalculateRank(doc.id);
      applyWorkflowRules(doc.id);
    }
    return result;
  }
};

exports.card_get = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    if(doc.type && doc.type == 'card'){
      if(doc.project_id && doc.id) {
        translation.emitTranslatedDoc(
          [doc.id, translation._keyTag],
          {
            _rev:         doc._rev,
            _id:          doc._id,
            project_id:   doc.project_id,
            id:           doc.id,
            category:     doc.category,
            description:  doc.description,
            status:       doc.status,
            title:        doc.title,
            created_at:   doc.created_at,
            updated_at:   doc.updated_at,
            init_lang:    doc.init_lang,
          },
          {title: true, description:true}
        );
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

