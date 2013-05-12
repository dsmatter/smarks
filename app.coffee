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
app.use auth.middleware()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use express.errorHandler() if "development" is app.get("env")

app.get "/", overview.get
app.get "/login", login.get
app.post "/login", login.post
app.get "/logout", (req, res) ->
  req.session = null
  res.redirect "/login"
app.get "/user", user.get
app.post "/user", user.post

app.get "/new_list", lists.create
app.delete "/list/:id", lists.remove
app.post "/list/:id", lists.post

app.post "/bookmark/new", bookmarks.create
app.delete "/bookmark/:id", bookmarks.remove
app.get "/bookmark/:id", bookmarks.get
app.post "/bookmark/:id", bookmarks.post
app.get "/quick_new", bookmarks.quick_get

# Start the server
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


