? extends 'common/base';

? block title => sub { 'favorites - ' . super() }

? block content => sub {
<ul id="statuses">
?     while (my $favorite = $c->stash->{favorites}->next) {
?         my $status = $favorite->status;
  <li class="status" id="<?= $status->id ?>">
    <span class="profile_image">
      <a href="/user/<?= $status->screen_name ?>">
        <img src="<?= $status->profile_image ?>" height="48" width="48" />
      </a>
    </span>
    <div class="body">
      <div>
        <span class="screen_name">
          <a href="/user/<?= $status->screen_name ?>">@<?= $status->screen_name ?></a>
        </span>
        <a href="/status/<?= $status->id ?>">
          <span class="created_at"><?= $status->created_at->strftime('%Y/%m/%d %H:%M:%S') ?></span>
        </a>
      </div>
      <span class="status_text"><?= $status->text ?></span>
    </div>
    <div class="buttons">
      <img class="heart" src="/img/heart_red.png" />
      <img class="tweet" src="/img/tweet.png" height="22" width="22" />
    </div>
  </li>
?     }
</ul>
<script type="text/javascript">
var token = "<?= $c->user->obj->token ?>";
$(function () {
    favorites();
});
</script>
? }
