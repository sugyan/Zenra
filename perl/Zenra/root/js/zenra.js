// $(function() {
//     $(".spread_button").click(function() {
//         return confirm("OAuthを使ってあなたのアカウントでつぶやきます。\nよろしいですか？");
//     });
// });

function status_template() {
    return $('\
<li class="status">\
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
</li>\
');
}

function home_timeline() {
    get_statuses($("#statuses"), token, "/api/home");
}

function user_timeline(screen_name) {
    get_statuses($("#statuses"), token, "/api/user/" + screen_name);
}

function get_statuses(container, token, api_url) {
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
            var template = status_template();
            for (var i = 0; i < data.statuses.length; i++) {
                var status  = data.statuses[i];
                var element = template.clone();
                element.find("span.profile_image")
                    .find("a").attr({ href: "/user/" + status.screen_name })
                    .find("img").attr({ src: status.profile_image });
                element.find("span.screen_name a")
                    .attr({ href: "/user/" + status.screen_name })
                    .text("@" + status.screen_name);
                var created_at = element.find("span.created_at");
                if (status.no_zenra) {
                    element.addClass("no_zenra");
                    created_at.text(status.created_at);
                } else {
                    created_at.html($("<a>")
                                    .attr({ href: "/status/" + status.id })
                                    .text(status.created_at));
                }
                element.find("div.body span.status_text").html(status.text);
                container.append(element);
            }
        },
        error: function() {
            container.html("api error");
        }
    });
}
