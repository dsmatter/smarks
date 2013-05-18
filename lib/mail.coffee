nodemailer = require 'nodemailer'
lists      = require "./model/list"
onerr      = require "./errorhandler"
async      = require "async"
_          = require "underscore"

transport = nodemailer.createTransport "sendmail"

mailOpts = ->
  from: "Bookmarks <bookmarks@smatterling.de>"

new_bookmark = (user, bookmark, callback) ->
  user_id = user._id ? user
  lists.get bookmark.list_id, onerr callback, (list) ->
    users = _.without list.users, user_id
    users = _.filter users, (user) -> user.email?.indexOf("@") > 0
    tasks = users.map (user) ->
      (c) ->
        opts = mailOpts()
        opts.to = user.email
        opts.subject = "New bookmark in #{list.title}"
        opts.text = bookmark.title + "\n\n" + bookmark.url
        transport.sendMail opts, (err) -> c err
    async.parallel tasks, (err) ->
      console.log err
      callback?()

exports.new_bookmark = new_bookmark
