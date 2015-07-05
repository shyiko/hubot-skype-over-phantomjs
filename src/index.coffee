{Adapter, TextMessage, User} = require 'hubot'
SkypeConnector = require './connector'

skypeBrainIdPrefix = "skype_message_"
skypeUrlSuffix = "/hubot/skype/"

###
  Unique message Id generator
###
uuid = do ->
  counter = 0
  ->
    counter++
    "#{(new Date).getTime()}#{counter}xxxxxxxx"
    .replace(/x/g, () -> (Math.random() * 10 | 0).toString())

###
  Truncates msg (not breaking the words) and
  adds 'stringToAdd' (if defined) so that
  resuling string length doesn't exceed given limit
###
truncateGracefully = (msg, stringToAdd, limit) ->
  buffer = []
  len = if stringToAdd? then stringToAdd.length else 0
  for w in msg.split(/\b/)
    len += w.length
    break if len > limit
    buffer.push w

  buffer.push stringToAdd if stringToAdd?
  buffer.join("")

###
  Skype adapter for hubot
  has possibility to trim messages to specified length
  and provide the link to the full message
###
class Skype extends Adapter

  constructor: (robot) ->
    super robot
    @options =
      username: process.env.HUBOT_SKYPE_USERNAME
      password: process.env.HUBOT_SKYPE_PASSWORD
      limit: process.env.HUBOT_SKYPE_MESSAGE_LIMIT
      excess: process.env.HUBOT_SKYPE_LINK_EXCESS
      url: process.env.HUBOT_SKYPE_BASE_URL

  send: (envelope, strings...) ->
    @preprocessAndSend(envelope.user.room, str) for str in strings

  reply: (envelope, strings...) ->
    handle = "@#{envelope.user.name.replace(/[ ]/g, '')}"
    @preprocessAndSend(envelope.user.room, "#{handle} #{str}") for str in strings

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

  ###
  Depending on environment settings truncates message
  to specified length and optionally adds link to the
  full version
  ###
  preprocessAndSend: (room, msg) ->
    limit = @options.limit
    if @options.excess && limit? && msg.length > limit
      id = uuid()
      @robot.brain.set(skypeBrainIdPrefix + id, msg)
      msg = truncateGracefully(msg,
        "\n ... view full: #{@options.url}#{skypeUrlSuffix}#{id}", limit)
    else if limit? && msg.length > limit
      msg = truncateGracefully(msg, null, limit)

    @connector.send(room, msg)

exports.use = (robot) ->
  ###
  If HUBOT_SKYPE_LINK_EXCESS is provided
  registers hubout http endpoint that returns
  full versions of truncated messages
  ###
  if process.env.HUBOT_SKYPE_LINK_EXCESS?
    robot.router.get "#{skypeUrlSuffix}:id", (req, res) ->
      id = skypeBrainIdPrefix + req.params.id.replace(/[^\d]/g, "_")
      res.setHeader 'content-type', 'text/plain; charset=utf-8'
      res.send robot.brain.get(id)

  new Skype robot
