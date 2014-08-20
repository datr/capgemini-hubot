# Description:
#   This script receives pages in the formats
#     /usr/bin/curl -d host="$HOSTALIAS$" -d output="$SERVICEOUTPUT$" -d description="$SERVICEDESC$" -d type=service -d state="$SERVICESTATE$" $CONTACTADDRESS1$
#     /usr/bin/curl -d host="$HOSTNAME$" -d output="$HOSTOUTPUT$" -d type=host -d state="$HOSTSTATE$" $CONTACTADDRESS1$
#
# Author:
#   oremj

module.exports = (robot) ->
  robot.router.post '/hubot/nagios/:room', (req, res) ->
    room = req.params.room
 
    host = req.body.host
    output = req.body.output
 
    state = req.body.state
    console.log "what?!"
    console.log room
    console.log state
    console.log req.body
    if state == 'OK'
      state += " :)"
    else if state == 'CRITICAL'
      state += " :'("
    else if state == 'WARNING'
      state += " (worry)"
    else
      state += ' :^)'
 
    if req.body.type == 'host'
      console.log "Sending message to #{room}"
      robot.messageRoom "#{room}", "nagios: #{host} is #{state}: #{output}"
    else
      service = req.body.description
      console.log "Sending messge to {room}"
      robot.messageRoom "#{room}", "nagios: #{host}:#{service} is #{state}: #{output}"
 
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
