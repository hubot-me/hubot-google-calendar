# Description:
#   Say Hi to Hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hello - "hello!"
#   hubot orly - "yarly"
#
# Author:
#   tombell


module.exports = (robot) ->

  # CronJob = require('cron').CronJob
  #
  # checkCalendars = new CronJob("0,5,10,15,20,25,30,35,40,45,50,55  * * * *", ()->
  #   # login to google calendars, refresh token if necessary
  #   #
  #   # for every user that is currently showing as available and has enabled gcal,
  #   #
  #   # robot.emit "googleapi:request",
  #   #   service: "analytics"
  #   #   version: "v3"
  #   #   endpoint: "management.profiles.list"
  #   #   params:                               # parameters to pass to API
  #   #   accountId: '~all'
  #   #   webPropertyId: '~all'
  #   #   callback: (err, data)->               # node-style callback
  #   #     return console.log(err) if err
  #   #     console.log data.items.map((item)->
  #   #     "#{item.name} - #{item.websiteUrl}"
  #   #     ).join("\n")
  #   #
  #   #   update their status.

  robot.respond /gcal set (.*)/i, (msg)->
    # in the brain, set the calendar name for that user to msg.match[1]
    calendarId   = msg.match[1]
    userId       = msg.user.id
    gcal         = robot.brain.get 'gcal'
    gcal[userId] = calendarId

    robot.brain.set 'gcal', gcal

  # robot.respond /gcal me/i, (msg)->
  #   robot.emit "googleapi:request",
  #     service: "analytics"
  #     version: "v3"
  #     endpoint: "management.profiles.list"
  #     params:                               # parameters to pass to API
  #     accountId: '~all'
  #     webPropertyId: '~all'
  #     callback: (err, data)->               # node-style callback
  #       return console.log(err) if err
  #       console.log data.items.map((item)->
  #       "#{item.name} - #{item.websiteUrl}"
  #       ).join("\n")
  #   # show all of their appointments for today

  # robot.respond //i, (msg) ->
  #   cheerio = require('cheerio')
  #   robot.http('http://en.wikiquote.org/wiki/Archer_%28TV_series%29').get() (error, result, body) ->
  #     if error
  #       msg.send "Encountered an error :( #{error}"
  #       return
  #     $ = cheerio.load(body)
  #     choices = $('dl').map (i, el) ->
  #       $(this).text()
  #     msg.send msg.random choices

