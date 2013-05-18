db     = require("../lib/couchdb")("test")
init   = require "./init"
expect = require("chai").expect
users  = require "../lib/model/user"
lists  = require "../lib/model/list"

describe "lists:", ->

  before (done) ->
    init.init_db "test", ->
      init.fill_test_user "testee", -> done()

  list_id = null

  it "should be able to create one", (done) ->
    list = lists.create "testee", "testlist"
    lists.insert list, (err, list) ->
      expect(err).not.to.exist
      expect(list).to.exist
      expect(list.title).to.equal "testlist"
      expect(list.users).to.include "testee"
      expect(list.users).to.have.length 1
      list_id = list._id
      done()

  it "should be able to fetch it", (done) ->
    lists.get list_id, (err, list) ->
      expect(err).not.to.exist
      expect(list).to.exist
      expect(list._id).to.equal list_id
      expect(list.title).to.equal "testlist"
      expect(list.users).to.include "testee"
      expect(list.bookmarks).to.be.empty
      done()

  it "should be able to fetch it by user", (done) ->
    users.fetch_lists "testee", (err, lists) ->
      expect(err).not.to.exist
      expect(lists).to.have.length 1

      list = lists[0]
      expect(list).to.exist
      expect(list._id).to.equal list_id
      expect(list.title).to.equal "testlist"
      expect(list.users).to.include "testee"
      done()

  it "should not be possible to fetch list by other user", (done) ->
    users.fetch_lists "foo", (err, lists) ->
      expect(err).not.to.exist
      expect(lists).to.exist
      list_ids = lists.map (list) -> list._id
      expect(list_ids).not.to.include list_id
      done()

  it "should not be possible to create a list without a user", (done) ->
    list = lists.create null, "impossible"
    lists.insert list, (err, list) ->
      expect(err).to.exist
      expect(err.message).to.contain "user"
      expect(list).not.to.exist

      list = lists.create "foo", "impossible"
      list.users = []
      lists.insert list, (err, list) ->
        expect(err).to.exist
        expect(err.message).to.contain "user"
        expect(list).not.to.exist
        done()

  it "should not be possible to create a titleless list", (done) ->
    list = lists.create "testee"
    list.title = null
    lists.insert list, (err, l) ->
      expect(err).to.exist
      expect(err.message).to.contain "title"
      expect(l).not.to.exist

      list.title = ""
      lists.insert list, (err, l) ->
        expect(err).to.exist
        expect(err.message).to.contain "title"
        expect(l).not.to.exist
        done()

