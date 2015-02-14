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
    console.log msg
    console.log robot
    # in the brain, set the calendar name for that user to msg.match[1]
    calendarId   = msg.match[1]
    userId       = msg.envelope.user.id
    gcal         = robot.brain.get('gcal') || {}
    gcal[userId] =
      id: userId
      calendarId: calendarId

    robot.brain.set 'gcal', gcal

  robot.respond /gcal me/i, (msg)->
    gcal   = robot.brain.get('gcal')
    userId = msg.envelope.user.id
    console.log "userId: ", userId
    console.log "gcal[userId]: ", gcal[userId]
    console.log "gcal[userId].calendarId: ", gcal[userId].calendarId
    robot.emit "googleapi:request",
      service: "calendar"
      version: "v3"
      endpoint: "events.list"
      params:
        timeMin: "2015-02-01T00:00:00.000Z"
        timeMax: "2015-02-28T00:00:00.000Z"
        calendarId: gcal[userId].calendarId
      callback: (err, data)->
        return console.log(err) if err
        items = data.items.map((item)->
          item.summary
        ).join("\n")
        console.log items
        msg.reply items

