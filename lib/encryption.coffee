crypto = require 'crypto'

module.exports =
  encode: (s, pw) ->
    cipher = crypto.createCipher 'aes192', pw
    cipher.write s
    cipher.final 'base64'

  decode: (s, pw) ->
    cipher = crypto.createDecipher 'aes192', pw
    cipher.write new Buffer s, 'base64'
    cipher.final('utf8')
