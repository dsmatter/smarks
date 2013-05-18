db     = require("../lib/couchdb")("test")
init   = require "./init"
expect = require("chai").expect
users  = require "../lib/model/user"
lists  = require "../lib/model/list"
cache  = require "../lib/cache"

describe "cache:", ->

  list_id = null

  before (done) ->
    init.init_db "test", ->
      init.fill_sharing_users (list) ->
        list_id = list.id
        done()

  it "should have created a shared list", (done) ->
    lists.get list_id, (err, list) ->
      expect(err).not.to.exist
      expect(list.title).to.equal "list1"
      expect(list.users).to.include "user1"
      expect(list.users).to.include "user2"
      done()

  it "should be able to set overview caches", (done) ->
    cache.set "overview", "user1", "foo", (err) ->
      expect(err).not.to.exist
      cache.set "overview", "user2", "foo", (err) ->
        expect(err).not.to.exist

        cache.get "overview", "user1", (err, c) ->
          expect(err).not.to.exist
          expect(c.valid).to.equal true
          expect(c.content).to.equal "foo"

          cache.get "overview", "user2", (err, c) ->
            expect(err).not.to.exist
            expect(c.valid).to.equal true
            expect(c.content).to.equal "foo"
            done()

  it "should invalidate both caches", (done) ->
    cache.invalidate_friend_overviews "user1", (err) ->
      expect(err).not.to.exist

      cache.get "overview", "user1", (err, c) ->
        expect(err).not.to.exist
        expect(c).to.exist
        expect(c.valid).to.equal false

        cache.get "overview", "user2", (err, c) ->
          expect(err).not.to.exist
          expect(c).to.exist
          expect(c.valid).to.equal false
          done()

