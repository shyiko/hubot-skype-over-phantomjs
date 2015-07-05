{Adapter, TextMessage, User} = require 'hubot'
uuid = require 'node-uuid'

SkypeConnector = require './connector'

truncateIfNeeded = (msg, ending, limit) ->
  msg.slice(0, limit - ending.length);

class Skype extends Adapter

  constructor: (robot) ->
    super robot
    @options =
      username: process.env.HUBOT_SKYPE_USERNAME
      password: process.env.HUBOT_SKYPE_PASSWORD
      limit: process.env.HUBOT_SKYPE_MESSAGE_LIMIT || 1000
      link: process.env.HUBOT_SKYPE_MESSAGE_LINK is 'on'
      linkBaseURL: (process.env.HUBOT_SKYPE_MESSAGE_LINK_BASE_URL or '').
        replace(/\/$/, '')

  send: (envelope, strings...) ->
    limit = @options.limit
    for msg in strings
      if limit && msg.length > limit
        if @options.link
          id = uuid.v1()
          @robot.brain.set("skype_message_#{id}", msg)
          msg = truncateIfNeeded(msg,
            "\n ... view full: #{@options.linkBaseURL}/skype/relay/#{id}", limit)
        else
          msg = truncateIfNeeded(msg, '', limit)
      @connector.send(envelope.user.room, msg)

  reply: (envelope, strings...) ->
    handle = "@#{envelope.user.name.replace(/[ ]/g, '')}"
    @send(envelope, ("#{handle} #{str}" for str in strings)...)

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
  if process.env.HUBOT_SKYPE_MESSAGE_LINK is 'on'
    robot.router.get "/skype/relay/:id", (req, res) ->
      res.setHeader 'content-type', 'text/plain; charset=utf-8'
      res.send robot.brain.get("skype_message_#{req.params.id}")

  new Skype robot
