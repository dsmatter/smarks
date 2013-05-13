users = require "../lib/model/user"
auth  = require "../lib/auth"

create_user = (username, password, callback) ->
  throw new Error "Please provide username and password" unless username? and password?

  user = users.create username
  user.password = auth.calculate_hash password, user.salt

  users.insert user, (err) ->
    throw err if err?
    console.log "User added"
    callback?()

module.exports = create_user

if require.main is module
  username = process.argv[2]
  password = process.argv[3]
  create_user username, password
