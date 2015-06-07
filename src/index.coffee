{Adapter, TextMessage, User} = require 'hubot'
SkypeConnector = require './connector'

class Skype extends Adapter

  constructor: (robot) ->
    super robot
    @options =
      username: process.env.HUBOT_SKYPE_USERNAME
      password: process.env.HUBOT_SKYPE_PASSWORD

  send: (envelope, strings...) ->
    @connector.send(envelope.user.room, str) for str in strings

  reply: (envelope, strings...) ->
    @connector.send(envelope.user.room, "@#{envelope.user.name} #{str}") for str in strings

  run: ->
    @robot.logger.debug "Skype adapter options: #{JSON.stringify @options}"
    @robot.logger.info 'Connecting Skype adapter...'
    @connector = new SkypeConnector(@options.username, @options.password)
    @connector.on 'message', (msg) =>
      user = new User(msg.contactId, room: msg.conversationId, name: msg.contactName)
      @receive new TextMessage(user, msg.body, msg.id)
    @connector.on 'connected', =>
      @robot.logger.info "Connected as @#{@robot.name}"
      @emit 'connected' # intended for Hubot
    @connector.connect()

  close: ->
    @connector.disconnect()

exports.use = (robot) ->
  new Skype robot
