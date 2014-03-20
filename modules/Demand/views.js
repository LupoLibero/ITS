exports.demand_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    var rank, list_id;

    if (doc.type) {
      switch(doc.type) {
        case 'demand_list':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag],
            {
              id:    doc.id,
              name:  doc.name,
              type:  doc.type,
            },
            {name: true}
          );
          break;
        case 'demand':
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
          emit([doc.project_id, 'default', doc.demand_id], doc);
          break;
        case 'payment':
          emit([doc.project_id, 'default', doc.demand_id], doc);
          break;
        case 'vote':
          if (doc.voted_doc_id.split('-')[0] == 'demand') {
            (function() {
              var demandId = doc.voted_doc_id.split('-')[1];
              emit(
                [
                  demandId.split('#')[0].toLowerCase(),
                  "default",
                  demandId
                ],
                {
                  voter: doc.voter,
                  vote: doc.vote,
                  demand_id: demandId,
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
      var demandDst, demandSrc, idDst, idSrc;
      //log([dst, "             ", src]);
      for (idDst in dst) {
        demandDst = dst[idDst];
        for (idSrc in src) {
          demandSrc = src[idSrc];
          if (demandDst.id == demandSrc.id) {
            newDst.push(demandSrc);
            alreadyPushed[demandDst.id] = true;
            continue;
          }
        }
        if (!alreadyPushed[demandDst.id]) {
          newDst.push(demandDst);
          alreadyPushed[demandDst.id] = true;
        }
      }
      for (idSrc in src) {
        demandSrc = src[idSrc];
        if (!alreadyPushed[demandSrc.id]) {
          newDst.push(demandSrc);
        }
      }
      return newDst;
    }

    var idx, id, e, i, doc;
    var result = {
      lists: [
        {id: 'ideas'},
        {id: 'todo'},
        {id: 'estimated'},
        {id: 'funded'},
        {id: 'doing'},
        {id: 'done'},
      ],
      demands: [],
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
        tagList = result.demands[i].tag_list;
        listId  = result.demands[i].list_id;
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
          case 'demand_list':
            for (var id in result.lists) {
              if (doc.id == result.lists[id].id) {
                result.lists[id] = recursive_merge(result.lists[id], doc, {});
              }
            }
            break;
          case 'cost_estimate':
            result.cost_estimate[doc.demand_id] = doc.estimate;
            //applyWorkflowRules(doc.demand_id);
            break;
          case 'payment':
            result.payment[doc.demand_id] = doc.amount;
            //applyWorkflowRules(doc.demand_id);
            break;
          case 'vote':
            result.votes[doc.demand_id] = result.votes[doc.demand_id] || {};
            result.votes[doc.demand_id][doc.voter] = doc.vote;
            //recalculateRank(doc.demand_id);
            break;
          case 'demand':
            i = result.demands.push(doc);
            reverseMapping[doc.id] = i - 1;
            result.cost_estimate[doc.id] = result.cost_estimate[doc.id] || 0;
            result.payment[doc.id] = result.payment[doc.id] || 0;
            result.rank[doc.id] = result.rank[doc.id] || 0;
            result.votes[doc.id] = result.votes[doc.id] || {};
            //recalculateRank(doc.id);
            //applyWorkflowRules(doc.id);
            break;
        }
      }
    }
    else {
      for(idx = 0 ; idx < values.length ; idx++){
        result = recursive_merge(result, values[idx],{
          demands: mergeArrayById,
          lists: mergeArrayById
        });
      }
    }
    log(result.cost_estimate);
    for (idx = 0 ; idx < result.demands.length ; idx++) {
      doc = result.demands[idx]
      log(doc);
      recalculateRank(doc.id);
      applyWorkflowRules(doc.id);
    }
    return result;
  }
};

exports.demand_get = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    if(doc.type && doc.type == 'demand'){
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

exports.demand_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "demand" && doc.project_id && doc.id){
      var splitId = doc.id.split('#');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
}

exports.demand_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'demand_vote') {
        if(doc.demand_id && doc.user_id){
          emit(doc.demand_id, 1);
        }
      }
    }
  },
  reduce: "_sum"
}

