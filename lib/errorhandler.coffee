module.exports = (err_callback, callback) ->
  (err, data) ->
    if err?
      err_callback? err
      return
    callback data
