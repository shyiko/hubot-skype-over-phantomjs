SocketIO = require('socket.io')
nodeModulePath = require('./node-module-path')
path = require('path')
spawn = require('child_process').spawn
EventEmitter = require('events').EventEmitter

class SkypeConnector extends EventEmitter

  constructor: (@username, @password) ->

  connect: ->
    throw new Error('Already connected') if @io
    @io = SocketIO()
    @io.on 'connection', (@socket) =>
      @socket
        .on 'initialized', =>
          @socket.on 'message', (data) =>
            return console.warn('Unexpected ' + JSON.stringify(data)) unless data.message?.info?.text
            @emit 'message',
              id: data.message.id
              conversationId: data.conversationId
              contactId: data.message.sender.id
              contactName: data.message.displayNameOverride || data.message.sender.id
              body: data.message.info.text
          @emit 'connected'
        .on 'disconnect', =>
          @emit 'disconnected'
      @socket.emit 'initialize', JSON.stringify({@username, @password})
    @io.listen 0
    @io.httpServer.on 'listening', =>
      port = @io.httpServer.address().port
      @_initPhantomSkype(port)

  _initPhantomSkype: (port) ->
    @phantomSocket = spawn(process.env.PHANTOMJS_BIN or 'phantomjs',
      [path.join(nodeModulePath('phantom-skype'), 'socketioIntegration.js'), "http://localhost:#{port}"])
    .on 'close', =>
      if (@io)
        console.warn "PhantomJS process #{@phantomSocket.pid} terminated unexpectedly. " +
          "RE-spawning..."
        setTimeout(@_initPhantomSkype.bind(@, port), 1000)
    @phantomSocket[out].on('data', (data) ->
      @emit "phantomjs_#{out}", data.toString()) for out in ['stdout', 'stderr']

  send: (conversationId, text) ->
    @socket.emit 'message', JSON.stringify({conversationId, text: text})

  disconnect: ->
    return unless @io
    @phantomSocket.disconnect()
    @io.close()
    @io = null

module.exports = SkypeConnector
