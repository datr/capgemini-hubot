# Description:
#   Display information about crucible reviews.
#
# Dependencies:
#   "request" : "",
#   "countdown" : ""
#
# Configuration:
#   HUBOT_CRUCIBLE_URL
#
# Commands:
#   <Project ID>-<Review ID> - Displays information about the review (if it exists)
#
# Author:
#   Dean Reilly

request = require 'request'
countdown = require 'countdown'

# keeps track of recently displayed issues, to prevent spamming
class RecentIssues
  constructor: (@maxage) ->
    @issues = []
  
  cleanup: ->
    for issue,time of @issues
      age = Math.round(((new Date()).getTime() - time) / 1000)
      if age > @maxage
        #console.log 'removing old issue', issue
        delete @issues[issue]
    0

  contains: (issue) ->
    @cleanup()
    @issues[issue]?

  add: (issue,time) ->
    time = time || (new Date()).getTime()
    @issues[issue] = time

module.exports = (robot) ->

  # how long (seconds) to wait between repeating the same RQM issue link
  issuedelay = process.env.HUBOT_CRUCIBLE_ISSUEDELAY || 30

  recentissues = new RecentIssues issuedelay

  get = (review_id, cb) ->
    url = process.env.HUBOT_CRUCIBLE_URL + "/rest-service/reviews-v1/" + review_id + "/details"
    console.log url

    request {url: url, headers: {Accept: 'application/json'}}, (error, response, body) ->
      if !error and response.statusCode == 200
        cb JSON.parse(body)

  info = (msg, review_id) ->
    get review_id, (review) ->
      console.log review.reviewers
      url = process.env.HUBOT_CRUCIBLE_URL + "/cru/" + review_id
      msg.send "[#{review_id}] #{review.name}. (#{review.author.displayName} / #{review.state}) #{url}"

      for reviewer in review.reviewers.reviewer then do (reviewer) ->
        complete = if reviewer.completed then "Complete" else "Incomplete"
        time = countdown(0, reviewer.timeSpent).toString();
        msg.send "[#{review_id}] Reviewer: #{reviewer.displayName} (#{complete} - #{time})"


  robot.hear /([^\w\-]|^)([0-9A-Za-z-]+-[0-9]+)(?=[^\w]|$)/ig, (msg) ->
    if msg.message.user.id is robot.name
      return

    for matched in msg.match
      review_id = (matched.match /([0-9A-Za-z-]+-[0-9]+)/i)[0]
      if !recentissues.contains msg.message.user.room+review_id
        info msg, review_id
        recentissues.add msg.message.user.room+review_id
