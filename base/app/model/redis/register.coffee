request = require "request"
async = require "async"
qs = require "querystring"

{ QpsExceededError, QpdExceededError } = require "../../../lib/error"
{ Redis } = require "../redis"

class exports.Register extends Redis
  @instantiateOnStartup = true
  @smallKeyName = "reg"

  isRegistered: ( cb ) ->
    @get "registered", ( err, value ) ->
      return cb err if err
      return cb null, ( value is "done" )

  register: ( email, name, cb ) ->
    # simple check for non-gibberish
    if ( not /@/.exec( email ) or not /\./.exec( email ) )
      return cb new Error "Invalid email address."

    options =
      strictSSL: false
      url: "https://test.apiaxle.com?#{ qs.stringify { email: email, name: name } }"
      timeout: 5000

    request.get options, ( err ) =>
      return cb err if err
      @set "registered", "done", cb
