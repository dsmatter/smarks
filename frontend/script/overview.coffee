require.config
  baseUrl: "/js/rjs"

require ["lists", "newest", "sidebar", "searchbar", "overlay"],
  (Lists, Newest, Sidebar, SearchBar, Overlay) ->

    $(document).ready ->
      Newest.attachTo $("#list-newest")
      SearchBar.attachTo $("#searchbar")
      Lists.attachTo $("#lists")
      Sidebar.attachTo $("#sidebar")
      Overlay.attachTo $(".overlay")
