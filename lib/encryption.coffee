crypto = require 'crypto'

module.exports =
  encode: (s, pw) ->
    cipher = crypto.createCipher 'aes192', pw
    encoded = cipher.update s, 'utf8', 'base64'
    encoded += cipher.final 'base64'

  decode: (s, pw) ->
    cipher = crypto.createDecipher 'aes192', pw
    decoded = cipher.update s, 'base64', 'utf8'
    decoded += cipher.final 'utf8'
