nodemailer = require 'nodemailer'
lists      = require "./model/list"
users      = require "./model/user"
onerr      = require "./errorhandler"
async      = require "async"
_          = require "underscore"

transport = nodemailer.createTransport "sendmail"

mailOpts = ->
  from: "Bookmarks <bookmarks@smatterling.de>"

new_bookmark = (user, bookmark, callback) ->
  user_id = user._id ? user
  lists.get bookmark.list_id, onerr callback, (list) ->
    mail_users = _.without list.users, user_id
    tasks = mail_users.map (user) ->
      (c) ->
        users.get user, (err, user) ->
          unless user? and user.email and user.email.indexOf("@") > 0
            return c()

          opts = mailOpts()
          opts.to = user.email
          opts.subject = "New bookmark in #{list.title}"
          opts.text = bookmark.title + "\n\n" + bookmark.url
          console.log "Sending mail to #{opts.to}"
          transport.sendMail opts, (err) -> c err
    async.parallel tasks, (err) ->
      console.log err
      callback?()

exports.new_bookmark = new_bookmark
