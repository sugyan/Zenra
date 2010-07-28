function status_template() {
    return $('\
<li class="status" id="">\
  <span class="profile_image">\
    <a href="">\
      <img src="" height="48" width="48" />\
    </a>\
  </span>\
  <div class="body">\
    <div>\
      <span class="screen_name">\
        <a href="" />\
      </span>\
      <span class="created_at" />\
    </div>\
    <span class="status_text" />\
  </div>\
  <div class="buttons">\
    <img class="heart" src="" />\
    <img class="tweet" src="/img/tweet.png" height="22" width="22" />\
  </div>\
</li>\
');
}

function home_timeline() {
    get_statuses($("#statuses"), "/api/home");
}

function user_timeline(screen_name) {
    get_statuses($("#statuses"), "/api/user/" + screen_name);
}

function favorites() {
    $("img.heart").click(fav_handler);
    $("img.tweet").click(twe_handler);
}

function fav_handler() {
    var target = $(this);
    var status_id = target.closest("li.status").attr("id");
    var prev_img  = target.attr("src");
    target.attr({ src: "/img/loading_mini.gif" });
    $.ajax({
        url:  "/api/favorite",
        type: "POST",
        data: {
            id: status_id,
            token: token
        },
        success: function(data) {
            if (data.error) {
                return;
            }
            if (data.result == "created") {
                target.attr({ src: "/img/heart_red.png" });
            } else {
                target.attr({ src: "/img/heart_gray.png" });
            }
        },
        error: function() {
            target.attr({ src: prev_img });
        }
    });
}

function twe_handler(status_id) {
    console.log(status_id);
    if (! confirm("OAuthを使用して、あなたのアカウントでTweetします。\nよろしいですか？")) {
        return false;
    }
    var target = $(this);
    var status_id = target.closest("li.status").attr("id");
    var prev_img  = target.attr("src");
    target.attr({ src: "/img/loading.gif" });
    $.ajax({
        url: "/api/tweet",
        type: "POST",
        data: {
            id: status_id,
            token: token
        },
        success: function(data) {
            target.attr({ src: "img/tweet_done.png" });
        },
        error: function() {
            target.attr({ src: prev_img });
        }
    });
}

function create_status_element(status) {
    var element = status_template().clone();
    element.attr({ id: status.id });
    element.find("span.profile_image")
        .find("a").attr({ href: "/user/" + status.screen_name })
        .find("img").attr({ src: status.profile_image });
    element.find("span.screen_name a")
        .attr({ href: "/user/" + status.screen_name })
        .text("@" + status.screen_name);
    var created_at = element.find("span.created_at");
    if (status.no_zenra || status.protected) {
        created_at.text(status.created_at);
        if (status.no_zenra) {
            element.addClass("no_zenra");
        }
        if (status.protected) {
            created_at.after($("<img>").attr({ src: "/img/lock.gif" }))
        }
        element.find("div.buttons").remove();
    } else {
        created_at.html($("<a>")
                        .attr({ href: "/status/" + status.id })
                        .text(status.created_at));
        var heart = element.find("img.heart");
        heart.attr({ src: "/img/heart_" + (status.favorited ? "red" : "gray") + ".png" })
        heart.click(fav_handler);
        var tweet = element.find("img.tweet");
        tweet.click(twe_handler);
    }
    element.find("div.body span.status_text").html(status.text.replace(/全裸で/g, '<span class="zenra">$&</span>'));

    return element;
}

function get_statuses(container, api_url) {
    container.html($("<img>").attr({
        id : "loading",
        src: "/img/loading.gif"
    }));
    $.ajax({
        url: api_url,
        data: { token: token },
        success: function(data) {
            container.empty();
            if (data.error) {
                container.text(data.error);
                return;
            }
            if (data.user_info) {
                var info = data.user_info;
                $("#name").text(info.name);
                $("#location").text(info.location);
                $("#url").text(info.url);
                $("#description").text(info.description);
            }
            for (var i = 0; i < data.statuses.length; i++) {
                container.append(create_status_element(data.statuses[i]));
            }
        },
        error: function() {
            container.html("api error");
        }
    });
}
