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

## License

[MIT License](https://github.com/shyiko/hubot-skype-over-phantomjs/blob/master/mit.license)

