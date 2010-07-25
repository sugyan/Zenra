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
    get_statuses("/api/home");
}

function user_timeline(screen_name) {
    get_statuses("/api/user/" + screen_name);
}

function get_statuses(api_url) {
    $.ajax({
        url: api_url,
        success: function(data) {
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
                $("#statuses").append(element);
            }
        },
        error: function() {
            console.log('error');
        }
    });
}
