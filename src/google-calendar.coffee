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

  robot.respond /gcal calendar (.*)/i, (msg)->
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
    robot.reply "OK, set your calendar to #{calendarId}"

  robot.respond /gcal look (.*) days ahead/, (msg)->
    daysAhead       = msg.match[1]
    userId          = msg.envelope.user.id
    gcal            = robot.brain.get('gcal') || {}
    gcal[userId]    = gcal[userId] || {}

    gcal[userId].id        = userId
    gcal[userId].daysAhead = daysAhead
    robot.reply "OK, your calendar, `gcal me` will show the next #{daysAhead} days"

  # TODO: robot.respond /gcal auto/ # enable/disable auto away behavior
  # TODO: robot.respond /gcal whereabouts/ # where is everyone
  # TODO: link to hangout
  # TODO: link to event on google calendar web

  robot.respond /gcal me/i, (msg)->
    moment = require('moment')
    gcal   = robot.brain.get('gcal')
    userId = msg.envelope.user.id
    console.log "userId: ", userId
    console.log "gcal[userId]: ", gcal[userId]
    console.log "gcal[userId].calendarId: ", gcal[userId].calendarId
    now = moment().toISOString()
    daysAhead = gcal[userId].daysAhead || 1
    in24 = moment().add(daysAhead,'days').toISOString()
    console.log "now ISO: #{now}"
    console.log "in 24 hrs ISO: #{in24}"
    robot.emit "googleapi:request",
      service: "calendar"
      version: "v3"
      endpoint: "events.list"
      params:
        timeMin: now
        timeMax: in24
        calendarId: gcal[userId].calendarId
      callback: (err, data)->
        return console.log(err) if err
        items = data.items.map((item)->
          start = moment(item.start.dateTime).format('H:MM')
          end = moment(item.end.dateTime).format('H:MM')
          "[#{start}-#{end}] '#{item.summary}' (#{item.location})"
        ).join("\n")
        console.log items
        message = if items.length > 0
                    "In the next 24 Hrs: #{items}"
                  else
                    "Sorry, no scheduled events in next 24 hrs."
        msg.reply message

