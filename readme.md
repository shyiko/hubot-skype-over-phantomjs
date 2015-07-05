# hubot-skype-over-phantomjs

Skype adapter for [Hubot](https://hubot.github.com/). 

It's built on top of [phantom-skype](https://github.com/ShyykoSerhiy/phantom-skype) which allows it to be used 
anywhere where PhantomJS can run (on you laptop, your Raspberry Pi, etc.).

# Installation

```sh
npm install hubot-skype-over-phantomjs --save
```

# Usage

```sh
HUBOT_SKYPE_USERNAME=<microsoft_account> HUBOT_SKYPE_PASSWORD=<password> hubot ... \
  --adapter skype-over-phantomjs
```

# Optional parameters

* ```HUBOT_SKYPE_MESSAGE_LIMIT=800``` — truncates the message to specified length. 
* ```HUBOT_SKYPE_LINK_EXCESS=true``` — used in conjuction with ```HUBOT_SKYPE_MESSAGE_LIMIT```. 
  If message is truncated stores it's full version in hubot brain and provides http link to it.
* ```HUBOT_SKYPE_BASE_URL=http://my.hubot.domain:8080``` — To use in conjunction with previous parameter.
  Protocol, domain and port where hubot is listening to http requests. 
  Without slash in the end. Basically the first part part of the generated url that points to the full 
   version of truncated message.

## License

[MIT License](https://github.com/shyiko/hubot-skype-over-phantomjs/blob/master/mit.license)

