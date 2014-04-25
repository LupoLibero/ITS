module.exports = {
  getChar: ->
    chars = "abcdefghijklmnopqrstuvwxyz"
    num   = Math.floor(Math.random() * chars.length)
    return chars.charAt(num)

  getString: ->
    string = ''
    for i in [10..1]
      string += @getChar()
    return string
}
