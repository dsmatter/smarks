db     = require("../lib/couchdb")("test")
init   = require "./init"
expect = require("chai").expect
users  = require "../lib/model/user"
auth   = require "../lib/auth"

describe "users:", ->

  before (done) ->
    init.init_db "test", done

  it "should be able to create one", (done) ->
    user = users.create "testee"
    users.set_password user, "test"
    expect(user).to.exist
    users.insert user, (err, user) ->
      expect(err).not.to.exist
      expect(user._id).to.exist
      done()

  it "should be able to fetch it", (done) ->
    users.get "testee", (err, user) ->
      expect(err).not.to.exist
      expect(user.username).to.equal "testee"
      done()

  it "should have consistent login information", (done) ->
    users.get "testee", (err, user) ->
      expect(err).not.to.exist
      expect(user.password).not.to.equal "test"
      expect(auth.authenticate user, "test").to.exist
      expect(auth.authenticate user, "testtt").not.to.exist
      done()

  it "should be able to create a token", (done) ->
    users.generate_token "testee", (err, user) ->
      expect(err).not.to.exist
      expect(user.tokens).not.to.be.empty
      token = user.tokens[0]

      users.get_by_token token, (err, user) ->
        expect(err).not.to.exist
        expect(user).to.exist
        expect(user.tokens).to.include token
        expect(user.username).to.equal "testee"
        done()

  it "should not be possible to create an empty username", (done) ->
    user = users.create ""
    users.insert user, (err, user) ->
      expect(err).to.exist
      expect(err.message).to.contain "username"
      expect(user).not.to.exist
      done()

  it "shoule not be possible to create a saltless user", (done) ->
    user = users.create "k2"
    expect(user.salt).not.to.be.empty
    user.salt = ""
    users.insert user, (err, user) ->
      expect(err).to.exist
      expect(err.message).to.contain "salt"
      expect(user).not.to.exist
      done()

  it "should not be possible to create a passwordless user", (done) ->
    user = users.create "k3"
    user.password = ""
    users.insert user, (err, user) ->
      expect(err).to.exist
      expect(err.message).to.include "password"
      expect(user).not.to.exist
      done()

  it "should not be possible to fetch a non-existent user", (done) ->
    users.get "k3", (err, user) ->
      expect(err).to.exist
      expect(err.message).to.contain "missing"
      expect(user).not.to.exist
      done()
