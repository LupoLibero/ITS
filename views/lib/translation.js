exports.translation = function () {
  return {
    _keyTag: '%lang%',
    defaultLang: '',
    langs: {},
    mostTranslatedLang: '',
    maxNbOfTranslations: 0,

   isTranslatableType: function (doc) {
      //return doc.type && types.hasOwnProperty(doc.type)
      return doc.hasOwnProperty('type') && doc.type == 'demand';
    },

    guessDefaultLang: function (doc) {
      if (doc.hasOwnProperty("init_lang")) {
        return this.defaultLang = doc.init_lang;
      }
      else {
        return this.defaultLang = this.mostTranslatedLang;
      }
    },

    registerAsTranslated : function (fieldName) {
      this.translatedFields[fieldName] = true;
    },

    isTranslated: function (doc, fieldName, translatableFields) {
      return translatableFields.hasOwnProperty(fieldName) &&
        typeof doc[fieldName] == 'object';
    },

    collectLangs: function (doc, fieldName) {
      var lang;
      for (lang in doc[fieldName]) {
        log(["lang", lang]);
        this.langs[lang] = this.langs[lang] ? this.langs[lang] + 1 : 1;
        if (this.langs[lang] > this.maxNbOfTranslations) {
          this.maxNbOfTranslations = this.langs[lang];
          this.mostTranslatedLang = lang;
        }
        else {
          if (this.langs[lang] == this.maxNbOfTranslations && lang == 'en') {
            this.mostTranslatedLang = lang;
          }
        }
      }
    },

    hasTranslation: function (doc, fieldName, lang) {
      return doc[fieldName].hasOwnProperty(lang);
    },

    hasDefaultTranslation: function (doc, fieldName) {
      return this.hasTranslation(doc, fieldName, this.defaultLang);
    },

    setTranslation: function (newDoc, doc, fieldName, lang) {
      newDoc[fieldName] = doc[fieldName][lang];
    },

    setDefaultTranslation: function (newDoc, doc, fieldName) {
      setTranslation(doc, fieldName, this.defaultLang, newDoc);
    },

    setFirstTranslation: function (newDoc, doc, fieldName) {
      var lang;
      for (lang in doc[fieldName]) {
        this.setTranslation(newDoc, doc, fieldName, lang);
        break;
      }
    },

    copyNonTranslatedContent: function (newDoc, doc, fieldName) {
      newDoc[fieldName] = doc[fieldName];
    },

    createTranslatedDoc: function (doc, lang, translatableFields) {
      var fieldName;
      newDoc = {lang: lang};
      for (fieldName in doc) {
        if (this.isTranslated(doc, fieldName, translatableFields)) {
          if (this.hasTranslation(doc, fieldName, lang)) {
            this.setTranslation(newDoc, doc, fieldName, lang);
          }
          else {
            if (this.hasDefaultTranslation(doc, fieldName)) {
              this.setTranslation(newDoc, doc, fieldName);
            }
            else {
              this.setFirstTranslation(newDoc, doc, fieldName);
            }
          }
        }
        else {
          this.copyNonTranslatedContent(newDoc, doc, fieldName);
        }
      }
      return newDoc;
    },

    keyReplacement: function (key, lang) {
      var newKey = [];
      for (var i in key) {
        if (key[i] == this._keyTag) {
          newKey[i] = lang;
        }
        else {
          newKey[i] = key[i];
        }
      }
      return newKey;
    },

    emitTranslatedDoc: function (key, doc, translatableFields) {
      var fieldName, newDoc, lang, atLeastOneTranslatedField = false;
      for (fieldName in translatableFields) {
        if (this.isTranslated(doc, fieldName, translatableFields)) {
          atLeastOneTranslatedField = true;
          this.collectLangs(doc, fieldName);
        }
      }
      if (atLeastOneTranslatedField) {
        this.guessDefaultLang(doc);
        log(["default", this.defaultLang, doc.id]);
        log(["langs", this.langs, doc.id]);
        for (lang in this.langs) {
          newDoc = this.createTranslatedDoc(doc, lang, translatableFields);
          newDoc.avail_langs = this.langs;
          emit(this.keyReplacement(key, lang), newDoc);
          if (lang == this.defaultLang) {
            emit(this.keyReplacement(key, 'default'), newDoc);
          }
        }
      }
      else {
        emit(this.keyReplacement(key, 'default'), doc);
      }
    }
  };
}
