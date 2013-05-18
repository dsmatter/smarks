db        = require("../lib/couchdb")("test")
init      = require "./init"
expect    = require("chai").expect
users     = require "../lib/model/user"
lists     = require "../lib/model/list"
bookmarks = require "../lib/model/bookmark"

describe "lists:", ->

  bookmark_id = null
  list_id = null

  before (done) ->
    init.init_db "test", ->
      init.fill_test_user "testee", ->
        init.fill_test_list "testlist", "testee", (list) ->
          list_id = list._id
          done()

  it "should be able to create a bookmark", (done) ->
    bm = bookmarks.create list_id, "foo", "http://google.de"
    bm.tags = ["test", "mocha"]
    bookmarks.insert bm, (err, bm) ->
      expect(err).not.to.exist
      expect(bm).to.exist
      expect(bm.title).to.equal "foo"
      expect(bm.url).to.equal "http://google.de"
      expect(bm.list_id).to.equal list_id
      bookmark_id = bm._id
      done()

  it "should be able to fetch it", (done) ->
    bookmarks.get bookmark_id, (err, bm) ->
      expect(err).not.to.exist
      expect(bm).to.exist
      expect(bm._id).equals bookmark_id
      expect(bm.title).to.equal "foo"
      expect(bm.url).to.equal "http://google.de"
      expect(bm.list_id).to.equal list_id
      done()

  it "should be able to fetch it by list", (done) ->
    lists.fetch_bookmarks list_id, (err, bms) ->
      expect(err).not.to.exist
      expect(bms).to.exist
      expect(bms).to.have.length 1
      bm = bms[0]
      expect(bm._id).equals bookmark_id
      done()

  it "should be able to fetch it by tag", (done) ->
    bookmarks.get_by_tag_user "test", "testee", (err, bms) ->
      expect(err).not.to.exist
      expect(bms).to.have.length 1
      bm = bms[0]
      expect(bm._id).equals bookmark_id
      expect(bm.title).equals "foo"
      expect(bm.tags).to.include "test"
      expect(bm.tags).to.include "mocha"
      done()

  it "should not be possible to fetch it by tag and another user", (done) ->
    bookmarks.get_by_tag_user "test", "eve", (err, bms) ->
      expect(err).not.to.exist
      bm_ids = bms.map (bm) -> bm._id
      expect(bm_ids).not.to.include bookmark_id
      done()

  it "should not be possible to create a listless bookmark", (done) ->
    bm = bookmarks.create null, "foo", "http://foo.com"
    bm.list_id = null
    bookmarks.insert bm, (err, b) ->
      expect(err).to.exist
      expect(err.message).to.contain "list"
      expect(b).not.to.exist
      done()

  it "should not be possible to create a titleless bookmark", (done) ->
    bm = bookmarks.create list_id, null, "http://empty.de"
    bm.title = null
    bookmarks.insert bm, (err, b) ->
      expect(err).to.exist
      expect(err.message).to.contain "title"
      expect(b).not.to.exist

      bm.title = ""
      bookmarks.insert bm, (err, b) ->
        expect(err).to.exist
        expect(err.message).to.contain "title"
        expect(b).not.to.exist
        done()

  it "should not be possible to create a URL-less bookmark", (done) ->
    bm = bookmarks.create list_id, "foo", null
    bm.url = null
    bookmarks.insert bm, (err, b) ->
      expect(err).to.exist
      expect(err.message).to.contain "url"
      expect(b).not.to.exist

      bm.url = ""
      bookmarks.insert bm, (err, b) ->
        expect(err).to.exist
        expect(err.message).to.contain "url"
        expect(b).not.to.exist
        done()

  it "should not be possible to create a bookmark with undefined tags", (done) ->
    bm = bookmarks.create list_id, "foo", "http://google.com"
    bm.tags = null
    bookmarks.insert bm, (err, b) ->
      expect(err).to.exist
      expect(err.message).to.contain "Tags"
      expect(b).not.to.exist
      done()
