# Description:
#   Report information about tickets from Rational Quality Manager.
#
# Dependencies:
#   "request" : ""
#
# Configuration:
#   HUBOT_RQM_URL
#   HUBOT_RQM_USER
#   HUBOT_RQM_PASSWORD
#   HUBOT_RQM_PROJECT
#
# Commands:
#   RQM<Issue ID> - Displays information about the RQM ticket (if it exists)
#
# Author:
#   Dean Reilly

request = require 'request'

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
  issuedelay = process.env.HUBOT_RQM_ISSUEDELAY || 30

  recentissues = new RecentIssues issuedelay

  request = request.defaults {jar: true, strictSSL: false}

  get = (issue_id, cb) ->
    url = process.env.HUBOT_RQM_URL + "/service/com.ibm.rqm.integration.service.IIntegrationService/resources/" + process.env.HUBOT_RQM_PROJECT + "/workitem/urn:com.ibm.rqm:" + issue_id
    console.log(url)

    request {url: url, headers: {Accept: 'application/json'}}, (error, response, body) ->
      if response.headers['x-com-ibm-team-repository-web-auth-msg'] == 'authrequired'
        authurl = process.env.HUBOT_RQM_URL + "/authenticated/identity"
        securl = process.env.HUBOT_RQM_URL + "/j_security_check"
        
        request authurl, (error, response, body) ->
          request.post securl, {form:{j_username: process.env.HUBOT_RQM_USER, j_password: process.env.HUBOT_RQM_PASSWORD}}, (error, response, body) ->
            request authurl, (error, response, body) ->
              request {url: url, headers: {Accept: 'application/json'}}, (error, response, body) ->
                console.log body
                cb JSON.parse(body)

      else
        console.log body
        cb JSON.parse(body)


  info = (msg, issue_id, cb) ->
    get issue_id, (issue) ->
      url = process.env.HUBOT_RQM_URL + "/web/console/" + process.env.HUBOT_RQM_PROJECT + "#action=com.ibm.team.workitem.viewWorkItem&id=" + issue_id
      cb "[RQM#{issue_id}] #{issue.workitem.title}. (#{issue.workitem.owner} / #{issue.workitem.state}) #{url}"

  robot.hear /([^\w\-]|^)(RQM ?[0-9]+)(?=[^\w]|$)/ig, (msg) ->
    if msg.message.user.id is robot.name
      return

    for matched in msg.match
      ticket = (matched.match /RQM ?([0-9]+)/i)[1]
      if !recentissues.contains msg.message.user.room+ticket
        info msg, ticket, (text) ->
          msg.send text
        recentissues.add msg.message.user.room+ticket
