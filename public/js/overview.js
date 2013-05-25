(function(){define("ajax",[],function(){var e,t,n;return t="#BB6D6D",n="#cae3ca",e=function(e,t,n){return e.animate({backgroundColor:t},100,function(){return e.css("background",""),typeof n=="function"?n():void 0})},function(n,r,i,s){var o;return typeof i=="function"&&(s=i,i={}),o=i.error,i.error=function(r){if(n!=null)return n.hideLoading(),e(n,t,function(){return typeof o=="function"?o(r):void 0})},i.success=function(e){return n!=null&&n.hideLoading(),s(e)},n!=null&&n.showLoading(),$.ajax(r,i)}})}).call(this),function(){define("selection",[],function(){return{setup:function(e){var t,n;return n=function(){return $(e).addClass("selected")},t=function(){return $(e).removeClass("selected")},$(e).hover(n,t)}}})}.call(this),function(){define("bookmark",["ajax","selection"],function(e,t){var n;return n=flight.component(function(){return this.getTitle=function(){return this.select("title").val()},this.getUrl=function(){return this.select("url").val()},this.getList=function(){return this.select("list_selection").val()},this.defaultAttrs({title:".title",url:".url",list_selection:".listselect"}),this.init_events=function(){var e,t,n=this;return e=function(){return n.trigger("update",{title:n.getTitle(),url:n.getUrl(),list:n.getList()})},t=function(t){if(t.which===13)return e()},this.select("title").keyup(t),this.select("url").keyup(t),this.select("list_selection").change(e)},this.after("initialize",function(){return this.init_events(),this.select("title").focus()})}),flight.component(function(){return this.update=function(t,n){var r=this;return e(this.$node,"/bookmark/"+this.attr.id,{type:"POST",data:n},function(e){return n.list===r.attr.list_id?r.trigger("replace_bookmark",{id:r.attr.id,html:e}):r.move(n.list),r.teardown()})},this.move=function(t){var n,r=this;return n=$("#list-"+this.attr.list_id),e(n,"/bookmark/"+this.attr.id+"/move/"+t,function(e){return r.trigger("refresh_list",{id:t}),r.trigger("replace_list",{id:r.attr.list_id,html:e})})},this.remove=function(t){var n=this;return e(this.$node,"/bookmark/"+this.attr.id,{type:"DELETE"},function(){return n.trigger("update_no_bookmarks",{add:-1}),n.$node.fadeOut().remove(),n.teardown()})},this.edit=function(){var t=this;return e(this.$node,"/bookmark/"+this.attr.id,function(e){return t.select("link").html(e),n.attachTo(t.select("link"))})},this.defaultAttrs({remove:".delete_bookmark",edit:".edit_bookmark",link:".link",tags:".tags"}),this.init_triggers=function(){return this.on("delete_bookmark",this.remove),this.on("edit",this.edit),this.on("update",this.update)},this.init_events=function(){var e=this;return this.select("remove").click(function(){return e.trigger("delete_bookmark")}),this.select("edit").click(function(){if(!(e.select("link").find("input").length>0))return e.trigger("edit")}),this.select("tags").find("a").click(function(t){return e.trigger("#searchbar","search",{text:$(t.target).text()})})},this.after("initialize",function(){return this.init_triggers(),this.init_events(),this.$node.find(".actions div").each(function(){return t.setup($(this))})})})})}.call(this),function(){define("list_mixin",[],function(){return function(){return this.filter=function(e,t){var n,r,i;if((t!=null?t.text:void 0)==null)return;return i=function(e){return e.toUpperCase().indexOf(t.text.toUpperCase())>=0},r=function(e){var t,n;return n=e.find(".link a").first().text(),i(n)?!0:(t=e.find(".tags a"),window._.any(t,function(e){return i($(e).text())}))},n=!1,this.select("bookmark").each(function(){return r($(this))?(n=!0,$(this).show()):$(this).hide()}),n?this.$node.show():this.$node.hide(),this.trigger("#sidebar","refresh")}}})}.call(this),function(){define("list",["ajax","bookmark","list_mixin","selection"],function(e,t,n,r){var i;return i=flight.component(function(){return this.after("initialize",function(){var t=this;return this.$node.keyup(function(n){var r;if(n.which!==13)return;return r=t.$node.val(),e(t.$node,"/list/"+t.attr.id,{type:"POST",data:{title:r}},function(){return t.$node.closest(".title").text(r),t.trigger("#sidebar","refresh"),t.teardown()})})})}),flight.component(function(){return flight.compose.mixin(this,[n]),this.update_no_bookmarks=function(e,t){var n,r;return r=this.$node.find("#nobookmarks-"+this.attr.id),n=this.select("bookmark").length,(t!=null?t.add:void 0)!=null&&(n+=t.add),n>0?r.addClass("hidden"):r.removeClass("hidden")},this.replace_bookmark=function(e,n){return this.$node.find("#bookmark-"+n.id).replaceWith(n.html),t.attachTo(this.$node.find("#bookmark-"+n.id),{id:n.id,list_id:this.attr.id})},this.new_bookmark=function(){var n=this;return e(this.$node,"/bookmark/new",{type:"POST",data:{list:this.attr.id}},function(e){var r,i;return n.$node.find(".bookmarks ul").first().prepend(e),i=$(e).attr("id"),r=n.$node.find("#"+i),t.attachTo(r,{id:i.replace("bookmark-",""),list_id:n.attr.id}),n.trigger("update_no_bookmarks"),n.trigger(r,"edit")})},this.remove=function(){var t=this;return e(this.$node,"/list/"+this.attr.id,{type:"DELETE"},function(){return t.$node.fadeOut().remove(),t.trigger("#sidebar","refresh"),t.teardown()})},this.edit_title=function(){var e,t;return t=this.select("title").text(),this.select("title").html("<input type='text' />"),e=this.select("title").find("input"),e.val(t),e.select(),i.attachTo(e,{id:this.attr.id})},this.defaultAttrs({bookmark:".bookmark",add:".addbookmark",unsubscribe:".delete",title:".title",sharing:".edit"}),this.init_triggers=function(){return this.on("replace_bookmark",this.replace_bookmark),this.on("filter",this.filter),this.on("update_no_bookmarks",this.update_no_bookmarks),this.on("delete_list",this.remove),this.on("edit_title",this.edit_title)},this.after("initialize",function(){var e=this;return this.init_triggers(),this.select("add").click(function(){return e.new_bookmark()}),this.select("unsubscribe").click(function(){if(confirm("Unsubscribe from "+e.select("title").text()+"?"))return e.trigger("delete_list")}),this.select("title").click(function(){if(!(e.select("title").find("input").length>0))return e.edit_title()}),this.select("sharing").click(function(){return e.trigger(".overlay","show_sharing",{id:e.attr.id})}),this.$node.find(".bookmark").each(function(n,r){var i;return i=$(r).attr("id").replace("bookmark-",""),t.attachTo($(r),{id:i,list_id:e.attr.id})}),this.$node.find(".bookmarklet").each(function(){var e;return e=$(this).attr("href"),e=e.replace("bm.smattr.de",window.location.host),$(this).attr("href",e)}),r.setup(this.$node.find(".button")),r.setup(this.$node.find(".title")),this.$node.find(".list_header .actions div").each(function(){return r.setup($(this))})})})})}.call(this),function(){define("lists",["ajax","list","selection"],function(e,t,n){return flight.component(function(){return this.refresh_list=function(t,n){var r,i=this;return r=this.$node.find("#list-"+n.id),e(r,"/list/"+n.id,function(e){return n.html=e,i.trigger("replace_list",n)})},this.replace_list=function(e,n){var r;return r="#list-"+n.id,this.$node.find(r).replaceWith(n.html),t.attachTo(this.$node.find(r),{id:n.id})},this.new_list=function(){var n=this;return e(this.$node,"/new_list",function(e){var r,i;return n.$node.append(e),n.trigger("#sidebar","refresh"),i=$(e).attr("id"),r=n.$node.find("#"+i),t.attachTo(r,{id:i.replace("list-","")})})},this.after("initialize",function(){var e=this;return this.on("replace_list",this.replace_list),this.on("refresh_list",this.refresh_list),this.$node.find(".list").each(function(){var e;return e=$(this).attr("id").replace("list-",""),t.attachTo($(this),{id:e})}),$("#addlist").click(function(){return e.new_list()}),n.setup($("#addlist"))})})})}.call(this),function(){define("newest",["ajax","list_mixin"],function(e,t){return flight.component(function(){return flight.compose.mixin(this,[t]),this.defaultAttrs({bookmark:".bookmark"}),this.init_triggers=function(){return this.on("filter",this.filter)},this.after("initialize",function(){var e=this;return this.init_triggers(),this.$node.find(".tags").find("a").click(function(t){return e.trigger("#searchbar","search",{text:$(t.target).text()})})})})})}.call(this),function(){define("sidebar",[],function(){return flight.component(function(){return this.create_list_element=function(e,t){var n;return n=e.replace("navi-",""),"<li id='"+e+"'><a href='#"+n+"'><i class='icon-chevron-right right'></i>"+t+"</a></li>"},this.get_selected=function(){var e;return e=null,this.select("entry").each(function(){if($(this).hasClass("active"))return e=$(this)}),e},this.position=function(){var e,t,n,r,i;return e=$("#content").position(),i=this.$node.width(),t=80,r=e.top,n=e.left-i-t,n<0&&(n=5),this.$node.css("position","fixed"),this.$node.css("top",r),this.$node.css("left",n)},this.init=function(){return this.fill(),this.position(),this.select("entry").first().addClass("active"),$("body").scrollspy("refresh"),this.$node.show()},this.fill=function(){var e=this;return $(".list:visible").each(function(t,n){var r,i;return n=$(n),r="navi-"+n.attr("id"),i=n.find(".title").text(),e.select("list").append(e.create_list_element(r,i))})},this.refresh=function(){var e,t,n;return e=(n=this.get_selected())!=null?n.attr("id"):void 0,this.select("entry").remove(),this.fill(),t=this.$node.find("#"+e),t.length===0&&(t=this.select("entry").first()),t.addClass("active"),$("body").scrollspy("refresh")},this.defaultAttrs({list:"ul",entry:"li"}),this.after("initialize",function(){return this.on("init",this.init),this.on("refresh",this.refresh),this.trigger("init")})})})}.call(this),function(){define("searchbar",[],function(){return flight.component(function(){return this.timer=null,this.search=function(e,t){var n=this;this.timer!=null&&clearTimeout(this.timer);if(t!=null?t.text:void 0)this.select("input").val(t.text),this.select("input").select();return $(".list").each(function(e,t){return n.trigger(t,"filter",{text:n.select("input").val()})})},this.defaultAttrs({input:"input"}),this.after("initialize",function(){var e=this;return this.on("search",this.search),this.select("input").keyup(function(){return e.timer!=null&&clearTimeout(e.timer),e.timer=setTimeout(function(){return e.search()},300)}),this.select("input").select()})})})}.call(this),function(){define("sharing",["ajax","selection"],function(e,t){var n,r;return r=flight.component(function(){return this.after("initialize",function(){var e=this;return this.attr.id=this.$node.attr("id").replace("user-",""),this.$node.find(".delete").click(function(){return e.trigger("delete_user",{user_id:e.attr.id})}),t.setup(this.$node)})}),n=flight.component(function(){return this.after("initialize",function(){var e=this;return this.$node.find(".user").each(function(t,n){var r;return r=$(n).attr("id").replace("user-",""),$(n).click(function(){return e.trigger("add_user",{user_id:r})})}),t.setup(this.$node.find(".user"))})}),flight.component(function(){return this.delete_user=function(t,n){var r,i=this;return r=this.$node.find("#user-"+n.user_id),e(r,"/lists/sharing/"+this.attr.id+"/user/"+n.user_id,{type:"DELETE"},function(){return r.fadeOut().remove(),i.trigger("refresh_friends"),i.trigger("#lists","refresh_list",{id:i.attr.id})})},this.refresh_friends=function(){var t,r=this;return t=this.$node.find("#add_friends"),e(t,"/lists/sharing/"+this.attr.id+"/friends",function(e){return t.replaceWith(e),n.attachTo(r.$node.find("#add_friends"))})},this.add_user=function(t,n){var i,s=this;return i=this.$node.find("#users"),e(i,"/lists/sharing/"+this.attr.id+"/add",{data:n},function(e){return i.append(e),r.attachTo(s.$node.find("#users .user").last()),s.trigger("refresh_friends"),s.trigger("#lists","refresh_list",{id:s.attr.id})})},this.after("initialize",function(){var e=this;return this.on("delete_user",this.delete_user),this.on("refresh_friends",this.refresh_friends),this.on("add_user",this.add_user),this.$node.find("#adduser").click(function(){return e.$node.find("#adduser_form").removeClass("hidden")}),this.$node.find(".user").each(function(e,t){return r.attachTo($(t))}),n.attachTo(this.$node.find("#add_friends")),this.$node.find("#email").keyup(function(t){if(t.which===13)return e.trigger("add_user",{user_email:$(t.target).val()})}),t.setup(this.$node.find(".button"))})})})}.call(this),function(){define("overlay",["ajax","sharing"],function(e,t){return flight.component(function(){return this.show_sharing=function(n,r){var i=this;return e($("body"),"/lists/sharing/"+r.id,function(e){return i.$node.find(".centerbox").html(e),i.$node.removeClass("hidden"),t.attachTo(i.$node.find("#sharing"),{id:r.id})})},this.defaultAttrs({box:".centerbox"}),this.after("initialize",function(){var e=this;return this.on("show_sharing",this.show_sharing),this.$node.click(function(){return e.$node.addClass("hidden")}),this.select("box").click(function(){return!1})})})})}.call(this),function(){require.config({baseUrl:"/js/rjs"}),require(["lists","newest","sidebar","searchbar","overlay"],function(e,t,n,r,i){return $(document).ready(function(){return t.attachTo($("#list-newest")),r.attachTo($("#searchbar")),e.attachTo($("#lists")),n.attachTo($("#sidebar")),i.attachTo($(".overlay"))})})}.call(this),define("../overview",function(){});