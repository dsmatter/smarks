express   = require "express"
http      = require "http"
path      = require "path"
overview  = require "./routes/overview"
login     = require "./routes/login"
user      = require "./routes/user"
lists     = require "./routes/lists"
bookmarks = require "./routes/bookmarks"
session   = require "./lib/session"
auth      = require "./lib/auth"
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

app.get "/new_list", [auth.check, lists.create]
app.get "/list/:id", [auth.check, lists.get]
app.delete "/list/:id", [auth.check, lists.remove]
app.post "/list/:id", [auth.check, lists.post]

app.post "/bookmark/new", [auth.check, bookmarks.create]
app.delete "/bookmark/:id", [auth.check, bookmarks.remove]
app.get "/bookmark/:id", [auth.check, bookmarks.get]
app.post "/bookmark/:id", [auth.check, bookmarks.post]
app.get "/bookmarks/quick_new", [auth.check, bookmarks.quick_get]
app.post "/bookmarks/quick_new", [auth.check, bookmarks.quick_post]
app.get "/bookmark/:bookmark_id/move/:list_id", [auth.check, bookmarks.move]

app.get "/lists/sharing/:id", [auth.check, lists.sharing]
app.get "/lists/sharing/:list_id/add", [auth.check, lists.sharing_add]
app.delete "/lists/sharing/:list_id/user/:user_id", [auth.check, lists.sharing_delete]

app.get "/tags/:tag", [auth.check, bookmarks.get_by_tag]

app.get "/success", (req, res) ->
  res.render "success"

# Start the server
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


