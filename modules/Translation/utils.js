
exports.registerTranslation = function (doc, form, type, element, lang) {
  if (!fields[type].fields[element].translatable) {
    return false
  }
  if(lang == undefined) {
    throw({forbidden: 'No language code'});
  }
  var value = null;
  if(form.hasOwnProperty(element)){
    value = form[element];
  } else {
    value = form.value;
  }
  if(typeof doc[element] != 'object') {
    doc[element] = {}
  }
  doc[element][lang] = value;
}
