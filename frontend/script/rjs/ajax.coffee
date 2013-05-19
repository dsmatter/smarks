define ->

  failColor = "#BB6D6D"
  successColor = "#cae3ca"

  color_animation = (element, color, callback) ->
    element.animate
      backgroundColor: color
    , 100, ->
      element.css "background", ""
      callback?()

  (element, url, opts, callback) ->
    if typeof opts is "function"
      callback = opts
      opts = {}

    orig_error_callback = opts.error

    opts.error = (err) ->
      if element?
        element.hideLoading()
        color_animation element, failColor, ->
          orig_error_callback? err

    opts.success = (data) ->
      element?.hideLoading()
      # color_animation element, successColor, ->
      callback data

    element?.showLoading()
    $.ajax url, opts
