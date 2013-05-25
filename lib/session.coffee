fs     = require "fs"
crypto = require "crypto"

secret_path = "session.secret"

read_secret = ->
  if fs.existsSync secret_path
    fs.readFileSync(secret_path).toString()
  else
    secret = generate_secret()
    fs.writeFileSync secret_path, secret
    secret.toString()

generate_secret = ->
  console.log "Generating session secret..."
  crypto.randomBytes 32

exports.read_secret = read_secret
