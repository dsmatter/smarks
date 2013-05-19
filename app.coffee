express   = require "express"
http      = require "http"
path      = require "path"
overview  = require "./routes/overview"
login     = require "./routes/login"
user      = require "./routes/user"
lists     = require "./routes/lists"
bookmarks = require "./routes/bookmarks"
api       = require "./routes/api"
session   = require "./lib/session"
auth      = require "./lib/auth"
uncache   = require("./lib/cache").middleware_invalidate_overview
app       = express()

### Configure express ###
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.cookieSession(secret: session.read_secret())
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use express.errorHandler() if "development" is app.get("env")

app.get "/", [auth.check, overview.get]
app.get "/login", login.get
app.post "/login", login.post
app.get "/logout", (req, res) ->
  req.session = null
  res.redirect "/login"
app.get "/user", [auth.check, user.get]
app.post "/user", [auth.check, user.post]

app.get "/new_list", [auth.check, uncache, lists.create]
app.get "/list/:id", [auth.check, lists.get]
app.delete "/list/:id", [auth.check, uncache, lists.remove]
app.post "/list/:id", [auth.check, uncache, lists.post]

app.post "/bookmark/new", [auth.check, uncache, bookmarks.create]
app.delete "/bookmark/:id", [auth.check, uncache, bookmarks.remove]
app.get "/bookmark/:id", [auth.check, bookmarks.get]
app.post "/bookmark/:id", [auth.check, uncache, bookmarks.post]
app.get "/bookmarks/quick_new", [auth.check, bookmarks.quick_get]
app.post "/bookmarks/quick_new", [auth.check, uncache, bookmarks.quick_post]
app.get "/bookmark/:bookmark_id/move/:list_id", [auth.check, uncache, bookmarks.move]

app.get "/lists/sharing/:id", [auth.check, lists.sharing]
app.get "/lists/sharing/:list_id/add", [auth.check, uncache, lists.sharing_add]
app.delete "/lists/sharing/:list_id/user/:user_id", [auth.check, uncache, lists.sharing_delete]
app.get "/lists/sharing/:id/friends", [auth.check, lists.sharing_friends]

# app.get "/tags/:tag", [auth.check, bookmarks.get_by_tag]
app.get "/newest", [auth.check, overview.get_newest]

app.get "/tokens/new", [auth.check, uncache, user.new_token]
app.delete "/tokens/:id", [auth.check, uncache, user.delete_token]

app.get "/success", (req, res) ->
  res.render "success"
app.get "/register", (req, res) ->
  res.render "register"

app.get "/api/lists", [auth.check, api.get_lists]
app.get "/api/bookmarks", [auth.check, api.get_all_bookmarks]
app.get "/api/bookmarks/add", [auth.check, uncache, api.add_bookmark]
app.get "/api/bookmarks/:id", [auth.check, api.get_bookmarks]

# Start the server
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


