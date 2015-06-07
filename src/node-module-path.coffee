path = require('path')

module.exports = (name) ->
  main = require.resolve(name)
  fragment = ['', 'node_modules', name, ''].join(path.sep)
  main.slice(0, main.lastIndexOf(fragment) + fragment.length - 1)
