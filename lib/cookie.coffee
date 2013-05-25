save_page = (req, res, next) ->
  req.session.saved_url = req.url
  next()

exports.save_page = save_page
