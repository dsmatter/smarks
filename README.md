# sMarks
A self-hosted bookmark service powered by [Node.js](http://nodejs.org), [Express](http://expressjs.com), [CouchDB](http://couchdb.org), and [CoffeeScript](http://coffeescript.org)

Ported from [my previous Ruby project](http://github.com/smatter0ne/bookmarks)

## Installation
### Requirements
- Node.js (including npm)
- CoffeeScript (npm install -g coffee-script)
- CouchDB

### Steps
    # Install dependencies
    npm install

    # Initialize the DB
    coffee util/init_db.coffee

    # Create first user
    coffee util/create_user.coffee testuser secret

    # Run the server
    coffee app.coffee

## Screenshot
![](http://home.in.tum.de/~strittma/bookmarks/bookmarks_screenshot.jpg)
