dateformat = require "dateformat"

format = "yyyy-mm-dd HH:MM"

now = ->
  dateformat new Date(), format

exports.now = now
