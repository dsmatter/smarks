var failColor = '#BB6D6D';
var successColor = '#66AF66';
var debug = 0;

function htmlDecode(str) {
    return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
}

var ajax = function(element, url, method, data) {
  method = method || 'GET';
  element.showLoading();

  var result = $.ajax({
    type: method,
    url: url,
    data: data
  });
  result.error(function() {
    element.hideLoading();
    failAnimation(element);
  });
  result.done(function() {
    element.hideLoading();
    succesAnimation(element);
  });
  return result;
};

var colorAnimation = function(element, color) {
  element.animate({
    backgroundColor: color
  }, 500, function() {
      element.css('background', '');
  });
};

var failAnimation = function(element) {
  colorAnimation(element, failColor);
};

var succesAnimation = function(element) {
  colorAnimation(element, successColor);
};

var updateNewest = function() {
  $('#list-newest').showLoading();
  $.ajax({
    type: 'GET',
    url: '/newest'
  }).done(function(newestHtml) {
    $('#list-newest').html(newestHtml);
    setupNewest();
    $('#list-newest').hideLoading();
  }).error(function() {
    $('#list-newest').hideLoading();
  });
};

var deleteList = function(element) {
  var listId = element.attr('id').replace('list-', '');
  ajax(element.find('.delete'), '/list/' + listId, 'DELETE').done(function() {
    element.fadeOut(function() {
      element.remove();

      if ($('.list').length === 0) {
        $('#nolists').removeClass('hidden');
      }
      updateNewest();
			fillSidebar();
      $('body').scrollspy('refresh');
    });
  });
};

var changeListTitle = function(element, newTitle, oldTitle) {
  var titleElement = element.find('.title');
  var listId = element.attr('id').replace('list-', '');

  ajax(element.find('.title'), '/list/' + listId, 'POST', { title: newTitle }).done(function() {
    titleElement.text(newTitle);
    setupStandardModeForTitle(titleElement);
		fillSidebar();
    $('body').scrollspy('refresh');
  }).error(function() {
    titleElement.text(oldTitle);
    setupStandardModeForTitle(titleElement);
  });
};

var changeBookmark = function(element, newTitle, newUrl, oldHtml) {
  var bookmarkId = element.attr('id').replace('bookmark-', '');

  ajax(element, '/bookmark/' + bookmarkId, 'POST', { title: newTitle, url: newUrl }).done(function(bookmarkHtml) {
    element.replaceWith(bookmarkHtml);
    newElement = $('#bookmark-' + bookmarkId);
    setupMouseOverFor(newElement);
    setupBookmark(newElement);
    updateNewest();
    $('body').scrollspy('refresh');
  }).error(function() {
    element.html(oldHtml);
    setupBookmark(element);
  });
};

var setupMouseOverFor = function(element) {
  $(element).hover(function() {
    $(this).addClass('selected');
  }, function() {
    $(this).removeClass('selected');
  });

  $(element).children().each(function() {
    setupMouseOverFor($(this));
  });
};

var setupMouseOver = function() {
  var hoverElements = ['div'];

  hoverElements.forEach(function(element) {
    setupMouseOverFor(element);
  });
};

var setupAddList = function() {
  $('#addlist').click(function() {
    ajax($(this), '/new_list').done(function(newListHtml) {
      $('#lists').append(newListHtml);
      setupLastList();
      $('body').scrollspy('refresh');
      $('#nolists').addClass('hidden');
    });
  });
};

var setupDeleteModeForList = function(element) {
  var confirm = element.find('.confirm');
  var cancel = element.find('.cancel');

  confirm.unbind('click');
  confirm.text('really?');
  confirm.click(function() {
    deleteList(element);
  });
  cancel.removeClass('hidden');
};

var setupStandardModeForList = function(element, text) {
  var confirm = element.find('.confirm');
  var cancel = element.find('.cancel');

  confirm.unbind('click');
  confirm.text(text);
  confirm.click(function() {
    setupDeleteModeForList(element);
  });
  element.find('.cancel').addClass('hidden');
};

var setupEditModeForTitle = function(element) {
  var text = element.text();
  var listElement = element.closest('.list');
  element.unbind('click');

  element.html('<input type="text" value="' + htmlDecode(text) + '" />');
  element.find('input').keypress(function(event) {
    if (event.which == 13) {
      changeListTitle(listElement, $(this).attr('value'), text);
    }
  });
  element.find('input').blur(function() {
    changeListTitle(listElement, $(this).attr('value'), text);
  });
  element.find('input').select();
};

var setupStandardModeForTitle = function(element) {
  element.unbind('click');
  element.click(function() {
    setupEditModeForTitle(element);
  });
};

var tagString = function(element) {
  var result = '';
  element.find('.tags li a').each(function() {
    result += ' ' + $(this).text();
  });
  return result;
};

var setupEditModeForBookmark = function(element) {
  var bookmarkId = element.attr('id').replace('bookmark-', '');

  var oldHtml = element.html();
  element.find('.edit_bookmark').unbind('click');

  ajax(element, '/bookmark/' + bookmarkId).done(function(editHtml) {
    element.find('.link').html(editHtml);
    element.find('input.title').select();

    element.find('input').keypress(function(event) {
      if (event.which == 13) {
        var newTitle = element.find('input.title').attr('value');
        var newUrl = element.find('input.url').attr('value');
        changeBookmark(element, newTitle, newUrl, oldHtml);
      }
    });
    element.find('.list_select select').change(function() {
        var newTitle = element.find('input.title').attr('value');
        var newUrl = element.find('input.url').attr('value');
        var newListId = $(this).find(':selected').val();

        changeBookmark(element, newTitle, newUrl, oldHtml);
        moveBookmark(element, newListId);
    });
  });
};

var setupStandardModeForBookmark = function(element) {
  element.find('.edit_bookmark').unbind('click');
  element.find('.edit_bookmark').click(function() {
    setupEditModeForBookmark(element);
  });
};

var moveBookmark = function(element, newList) {
  var bookmarkId = element.attr('id').replace('bookmark-', '');

  ajax(element, '/bookmark/' + bookmarkId + '/move/' + newList).done(function(oldListHtml) {
    var currentList = $(oldListHtml).attr('id').replace('list-', '');
    $('#list-' + currentList).replaceWith(oldListHtml);
    var newOldList = $('#list-' + currentList);
    setupMouseOverFor(newOldList);
    setupList(newOldList);

    ajax($('#list-' + newList), '/list/' + newList).done(function(listHtml) {
      $('#list-' + newList).replaceWith(listHtml);
      newList = $('#list-' + newList);
      setupMouseOverFor(newList);
      setupList(newList);

      succesAnimation($('#bookmark-' + bookmarkId));
    });
  });
};

var setupList = function(element) {
  var listId = element.attr('id').replace('list-', '');

  element.find('.edit').click(function() {
    // Get overlay content
    ajax($(this), '/lists/sharing/' + listId).done(function(overlayContent) {
      $('.overlay .centerbox').html(overlayContent);
      setupSharing(listId);
      showOverlay();
    });
  });

  element.droppable({
    drop: function(e, ui) {
      moveBookmark(ui.draggable, listId);
    },
    accept: '.bookmark',
    hoverClass: 'draghover'
  });

  element.find('.title').click(function() {
    setupEditModeForTitle($(this));
  });

  var oldText = element.find('.confirm').text();
  element.find('.confirm').click(function() {
    setupDeleteModeForList(element);
  });
  element.find('.cancel').click(function() {
    setupStandardModeForList(element, oldText);
  });

  element.find('.addbookmark').click(function() {
    ajax($(this), '/bookmark/new', 'POST', { list: listId }).done(function(newBookmarkHtml) {
      element.find('.bookmarks').find('ul').first().prepend(newBookmarkHtml);
      $('#nobookmarks-' + listId).hide();
      setupFirstBookmark(element);
      updateNewest();
      $('body').scrollspy('refresh');
    });
  });

  element.find('.bookmark').each(function() {
    setupBookmark($(this));
  });
};

var showUserMenu = function() {
  // TODO: show friends

  $('#adduser_form').removeClass('hidden').hide().fadeIn();
  $('#adduser_form #email').select();
};

var setupSharingUser = function(element, listId) {
  var userId = element.attr('id').replace('user-', '');

  element.find('.delete').click(function() {
    ajax($(this).closest('.user'), '/lists/sharing/' + listId + '/user/' + userId, 'DELETE').done(function() {
      element.fadeOut().remove();
      reloadList(listId);
    });
  });
  setupMouseOverFor(element);
};

var setupSharingFriend = function(element, listId) {
  var userId = element.attr('id').replace('user-', '');

  element.click(function() {
    ajax($(this).closest('.user'), '/lists/sharing/' + listId + '/add', 'GET', { user_id: userId }).done(function(newUserHtml) {
      $('#users').append(newUserHtml);
      setupSharingUser($('#sharing #users .user').last(), listId);
      $('#adduser_form #email').select();
      reloadList(listId);
    }).error(function() {
      $('#adduser_form #email').select();
    });
  });
};

var setupSharing = function(listId) {
  $('#adduser').click(function() {
    showUserMenu();
  });

  $('#adduser_form').keypress(function(event) {
    if (event.which == 13) {
      ajax($(this), '/lists/sharing/' + listId + '/add', 'GET', { user_email: $(this).find('#email').attr('value')}).done(function(newUserHtml) {
        $('#users').append(newUserHtml);
        setupSharingUser($('#sharing #users .user').last(), listId);
        $('#adduser_form #email').select();
        reloadList(listId);
      }).error(function() {
        $('#adduser_form #email').select();
      });
    }
  });

  $('#sharing #users .user').each(function() {
    setupSharingUser($(this), listId);
  });
  $('#sharing #add_friends .user').each(function() {
    setupSharingFriend($(this), listId);
  });
};

var reloadList = function(listId) {
  var listElement = $('#list-' + listId);
  ajax(listElement, '/list/' + listId).done(function(listHtml) {
    listElement.replaceWith(listHtml);

    // Get and setup new list element
    listElement = $('#list-' + listId);
    setupMouseOverFor(listElement);
    setupList(listElement);
  });
};

var setupBookmark = function(element) {
  var bookmarkId = element.attr('id').replace('bookmark-', '');

  element.draggable({
    distance: 100,
    helper: 'clone',
    revert: 'invalid'
  });

  element.find('.edit_bookmark').click(function() {
    setupEditModeForBookmark($(this).closest('.bookmark'));
  });

  element.find('.delete_bookmark').click(function() {
    var bookmarkLi = $(this).closest('li');
    ajax($(this), '/bookmark/' + bookmarkId, 'DELETE').done(function() {
      if (bookmarkLi.closest('ul').find('li').size() == 2) {
        bookmarkLi.closest('ul').find('li').first().removeClass('hidden').show();
      }
      bookmarkLi.fadeOut().remove();
      updateNewest();
      $('body').scrollspy('refresh');
    });
  });
};

var setupFirstBookmark = function(list) {
  var firstBookmark = list.find('.bookmark').first();
  $('body').animate({
    scrollTop: firstBookmark.closest('.list').offset().top
  }, 0);
  firstBookmark.hide().fadeIn();
  setupBookmark(firstBookmark);
  setupMouseOver(firstBookmark);
  setupEditModeForBookmark(firstBookmark);
};

var setupLastList = function() {
  var lastList = $('.list').last();
  lastList.hide().fadeIn();
  setupList(lastList);
  setupMouseOverFor(lastList);
  setupEditModeForTitle(lastList.find('.title'));
};

var setupNewest = function() {
  $('#list-newest .actions').each(function() {
    var bmId = $(this).closest('.bookmark').attr('id');
    $(this).empty();
    $(this).html('<a href="#' + bmId + '">➜</a>');
  });
  $('#list-newest .bookmark').attr('id', '');
};

var setupLists = function() {
  setupNewest();

  $('#lists .list').each(function() {
    setupList($(this));
  });
};

var setupToken = function(element) {
  var tokenId = element.attr('id').replace('token-', '');

  element.find('.delete').click(function() {
    ajax(element, '/tokens/' + tokenId, 'DELETE').done(function() {
      element.fadeOut().remove();
    });
  });
};

var setupUser = function() {
  setupUserForm($('#user_form'));

  $('#addtoken').click(function() {
    ajax($(this), '/tokens/new').done(function(newTokenHtml) {
      $('#tokens').append(newTokenHtml);
      setupToken($('.token').last());
    });
  });

  $('.token').each(function() {
    setupToken($(this));
  });
};

var hideOverlay = function() {
  $('.overlay').fadeOut();
};

var showOverlay = function() {
  setupMouseOverFor($('.overlay'));
  $('.overlay').removeClass('hidden').hide().fadeIn();
};

var setupOverlay = function() {
  $('.overlay').click(function() {
    hideOverlay();
  });
  $('.overlay .centerbox').click(function(e) {
    e.stopPropagation();
  });
};

var setupOverview = function() {
  setupOverlay();
  setupLists();
  setupAddList();
  setupSearch();
  setupSidebar();
  setupBookmarklets();
};

var setupBookmarklets = function() {
  $(".bookmarklet").each(function() {
    bm = $(this).attr("href");
    bm = bm.replace("bm.smattr.de", window.location.host);
    $(this).attr("href", bm);
  });
};

var setupQuickNew = function() {
  $('#title').select();
};

var setupRegister = function() {
  setupUserForm($('#registration_form'));
};

var setupUserForm = function(formElement) {
  var usernameElement = formElement.find('.username');
  var passphraseElement = formElement.find('.passphrase');
  var passphraseConfirmationElement = formElement.find('.passphrase_confirmation');
  var emailElement = formElement.find('.email');

  // Initial validation
  setInterval(function() {
    showValidation(usernameElement, validateUsername);
    showValidation(passphraseElement, validatePassphrase);
    showValidation(passphraseConfirmationElement, validatePassphraseConfirmation);
    showValidation(emailElement, validateEmail);
  }, 1000);

  usernameElement.find('input').keyup(function(e) {
    showValidation(usernameElement, validateUsername);
  });
  passphraseElement.find('input').keyup(function(e) {
    showValidation(passphraseElement, validatePassphrase);
  });
  passphraseConfirmationElement.find('input').keyup(function(e) {
    showValidation(passphraseConfirmationElement, validatePassphraseConfirmation);
  });
  emailElement.find('input').keyup(function(e) {
    showValidation(emailElement, validateEmail);
  });

};

var showValidation = function(element, validator) {
  validator(element, function(ok) {
    changeValidation(element, ok);
  });
};

var validateUsername = function(element, callback) {
  var inputElement = element.find('input');
  var text = inputElement.val();

  if (text.length < 3 || text.length > 40) {
    callback(false);
    return;
  }
  callback(true);
};

var checkUsername = function(username, callback) {
  $.ajax({
    type: 'POST',
    url: '/api/username/check',
    data: { username: username }
  }).done(function() {
    callback(false);
  }).error(function() {
    callback(true);
  });
};

var validatePassphrase = function(element, callback) {
  var inputElement = element.find('input');
  var text = inputElement.val();

  if (text.length < 6 || text.length > 40) {
    callback(false);
    return;
  }
  callback(true);
};

var validatePassphraseConfirmation = function(element, callback) {
  var inputElement = element.find('input');
  var text = inputElement.val();
  var cmpText = element.closest('form').find('.passphrase input').val();

  callback(cmpText.length > 0 && text == cmpText);
};

var validateEmail = function(element, callback) {
  var inputElement = element.find('input');
  var text = inputElement.val();

  callback(text.length > 3 && text.match(/^\S+@\S+\.\w+$/));
};

var changeValidation = function(element, ok) {
  var statusElement = element.find('.status');
  if (ok) {
    statusElement.removeClass('fail').addClass('ok').text('ok');
  } else {
    statusElement.removeClass('ok').addClass('fail').text('✗');
  }
};

var setupLogin = function() {
  $('input[name=user]').select();
};

var setupCommon = function() {
  setupMouseOver();
  $('input').first().select();
};

var setupTags = function() {
  $('.bookmark').each(function() {
    setupBookmark($(this));
  });
};

var setupSearch = function() {
  var onNewText = function(text) {
    filterBookmarks(text);
  };
  var searchElement = $('#searchbar input');
  searchElement.change(function() {
    onNewText(searchElement.val());
  });
  searchElement.keyup(function() {
    onNewText(searchElement.val());
  });
  // setInterval(function() {
  //   if ($('.overlay').is(':hidden')) {
  //     onNewText(searchElement.val());
  //   }
  // }, 2000);
};

var matchText = function(haystack, needle) {
  match = true;
  needle.split(" ").forEach(function(needle) {
    if (!match) {
      return;
    }
    if (haystack.toUpperCase().indexOf(needle.toUpperCase()) < 0) {
      match = false;
    }
  });
  return match;
};

var filterBookmarks = function(text) {
  $('.bookmark').each(function() {
    var title = $(this).find('a').text();
    var tags = $(this).find('.tags');

    match = false;
    tags.find('li').each(function() {
      if (match) { return; }
      match = matchText($(this).text(), text);
    });

    if (!match) {
      match = matchText(title, text);
    }

    if (match) {
      $(this).removeClass('hidden');
    } else {
      $(this).addClass('hidden');
    }
  });
  $('.list').each(function() {
    var hasVisible = false;
    $(this).find('.bookmarks li').each(function() {
      // Exclude tags
      if ($(this).parent().parent().hasClass('tags')) {
        return;
      }
      // Exclude "no bookmarks" banner if search is empty
      if (text !== "" && $(this).hasClass('hi')) {
        return;
      }
      if (!$(this).hasClass('hidden')) {
        hasVisible = true;
        return;
      }
    });
    if (!hasVisible) {
      $(this).addClass('hidden');
    } else {
      $(this).removeClass('hidden');
    }
  });
};

var positionSidebar = function() {
	var contentPos = $('#content').position();
	var sidebarWidth = $('#sidebar').width();
	var paddingLeft = 80;

  var posTop = contentPos.top;
  var posLeft = contentPos.left - sidebarWidth - paddingLeft;

  if (posLeft < 0) {
    $('#sidebar').css('top', 5);
    $('#sidebar').css('left', 5);
  } else {
    $('#sidebar').css('top', posTop);
    $('#sidebar').css('left', posLeft);
  }
  $('#sidebar').fadeIn();
};

var fillSidebar = function() {
  // Save active entry
  var active_id;
  var found_active = false;
  $('#sidebar ul li').each(function() {
    if ($(this).hasClass('active')) {
      active_id = $(this).attr('id');
    }
  });

	// Clear list
	$('#sidebar ul').empty();

	// Add hide button
	// $('#sidebar ul').append(makeSidebarLi('hideSidebar', '[hide]'));
	// $('#hideSidebar').click(function() {
	// 	$('#sidebar ul li').fadeOut();
	// 	$('#sidebar ul').append(makeSidebarLi('showSidebar', '[show]'));
	// 	setupMouseOverFor($('#showSidebar'));
	// 	$('#showSidebar').click(function() {
 //      fillSidebar();
 //    });
	// });

	// Fill list
	$('.list').each(function() {
    var id = "navi-" + $(this).attr('id');
    var title = $(this).find('.title').text();
    $('#sidebar ul').append(makeSidebarLi(id, title));

    if (id == active_id) {
      $('#sidebar ul li').last().addClass('active');
      found_active = true;
    }
    // $('#' + id).click(function() {
    //  var listId = $(this).attr('id').replace(/navi-/, '');
    //  $('body').animate({
    //   scrollTop: $('#' + listId).offset().top
    // }, 0);
   // });
  });
  if (!found_active) {
    $('#sidebar li').first().addClass('active');
  }
	setupMouseOverFor($('#sidebar ul'));
};

var makeSidebarLi = function(id, title) {
  var listId = id.replace('navi-', '');
  return '<li id="' + id + '"><a href="#' + listId + '"><i class="icon-chevron-right right"></i>' + title + '</a></li>';
};

var setupSidebar = function() {
	fillSidebar();
	setTimeout(positionSidebar, 100);
  $('#sidebar').scrollspy();
  $('body').scrollspy('refresh');
};

var setupSuccess = function() {
  setTimeout(function() { window.location.pathname = '/'; }, 1000);
};

$(document).ready(function() {
  setupCommon();

  if (window.location.pathname.match(/^\/$/)) {
    setupOverview();
  } else if (window.location.pathname.match(/^\/user/)) {
    setupUser();
  } else if (window.location.pathname.match(/quick_new/)) {
    setupQuickNew();
  } else if (window.location.pathname.match(/^\/register/)) {
    setupRegister();
  } else if (window.location.pathname.match(/^\/login/)) {
    setupLogin();
  } else if (window.location.pathname.match(/^\/tags/)) {
    setupTags();
  } else if (window.location.pathname.match(/^\/success/)) {
    setupSuccess();
  }
});

