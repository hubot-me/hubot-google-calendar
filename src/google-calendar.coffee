# Description:
#   Get google calendar information from Hubot
#
# Dependencies:
#   "coffee-script": "~1.6",
#   "moment": "~2.9.0",
#   "moment-timezone": "~0.3.0"
#   "hubot-googleapis": "~0.2.0"
#
# Configuration:
#   GOOGLE_API_CLIENT_ID      # hubot-googleapi
#   GOOGLE_API_CLIENT_SECRET  # hubot-googleapi
#   GOOGLE_API_SCOPES         # hubot-googleapi
#
# Commands:
#   hubot gcal me - "Retrieves the events for the immediate future (defaults to a day)."
#   hubot gcal calendar some.calendar@example.com - "Sets the calendar for the current user."
#   hubot gcal look 10 days ahead - "Calls to `gcal me` will return 10 days worth of events."
#   hubo gcal timezone America/Phoenix - "Sets the timezone for the current user."
#
# Author:
#   hubot-me

# TODO: robot.respond /gcal auto/ # enable/disable auto away behavior
# TODO: robot.respond /gcal whereabouts/ # where is everyone
# TODO: for recurring, make sure I'm showing the next occurrence, and all after that
# TODO: set the cron interval for auto-away status updates
# TODO: discard events not in the future

module.exports = (robot) ->

  moment = require('moment')
  require('moment-timezone')
  _ = require('lodash')

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
    msg.reply "OK, your calendar, `gcal me` will show the next #{daysAhead} days."

  # make every effort to return the correct timezone - http://momentjs.com/timezone/
  robot.respond /gcal timezone (.*)/, (msg)->
    timeZone     = msg.match[1]
    userId       = msg.envelope.user.id
    gcal         = robot.brain.get('gcal') || {}
    gcal[userId] = gcal[userId] || {}

    gcal[userId].id       = userId
    gcal[userId].timeZone = timeZone
    msg.reply "OK, your calendar, `gcal me` will reflect your timzone, #{timeZone}."

  # return the calendar events for the immediate future
  robot.respond /gcal me/i, (msg)->
    userId = msg.envelope.user.id
    unless userId
      msg.reply "You need to set your calendar with my.email@example.com first"
    gcal = robot.brain.get('gcal')
    now = moment().toISOString()
    daysAhead = gcal[userId].daysAhead || 1
    in24 = moment().add(daysAhead,'days').toISOString()
    robot.emit "googleapi:request",
      service: "calendar"
      version: "v3"
      endpoint: "events.list"
      params:
        timeMin: now
        timeMax: in24
        calendarId: gcal[userId].calendarId
        singleEvents: true
      callback: (err, data)->
        return console.log(err) if err
        console.log data.items
        message = ""
        timeZone = gcal[userId].timeZone
        items = _
          .map(data.items, (item)->
            if item.start.date
              start = item.start.date
              end = item.end.date
              format = 'M/D'
            else
              start = item.start.dateTime
              end = item.end.dateTime
              format = 'M/D h:mm'

            start = moment(start)
            start = start.tz(timeZone || item.start.timeZone || 'America/New_York')

            end = moment(end)
            end = end.tz(timeZone || item.end.timeZone || 'America/New_York')

            entry =  "[#{start.format(format)}-#{end.format(format)}]  #{item.summary}\n"
            # entry += "[#{start.toString()}-#{end.toString()}]\n"
            entry += "(#{item.location})\n" if item.location
            entry += "event   => #{item.htmlLink}\n"
            entry += "hangout => #{item.hangoutLink}\n" if item.hangoutLink
            entry
          .join "\n"
        console.log items
        message += if items.length > 0
                     "In the next #{daysAhead} day(s): \n#{items}"
                   else
                     "Sorry, no scheduled events in next #{daysAhead} days."
        msg.reply message

