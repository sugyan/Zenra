? extends 'common/base';

? my $status = $c->stash->{status};
? block content => sub {
<div id="content">
  <div class="status" id="<?= $status->id ?>">
    <span class="text"><?= raw_string($status->text) ?></span>
? if ($c->user) {
    <div class="buttons">
      <img id="heart_button" src="/img/heart_<?= $c->stash->{favorited} ? 'red' : 'gray' ?>.png" height="19" width="25" />
      <img id="tweet_button" src="/img/tweet.png" height="22" width="22" />
    </div>
? }
    <span class="meta"><?= $status->created_at->strftime('%Y/%m/%d %H:%M:%S') ?></span>
    <div class="user_info">
      <div class="icon"><img src="<?= $status->profile_image ?>" /></div>
      <div class="screen_name">
        <a href="/user/<?= $status->screen_name ?>"><?= $status->screen_name ?></a>
      </div>
      <div class="name"><?= $status->name ?></div>
    </div>
  </div>
  <div class="favorites">
    <ul>
? while (my $favorite = $c->stash->{favorites}->next) {
      <li>
        <a href="/user/<?= $favorite->user->screen_name ?>">@<?= $favorite->user->screen_name ?></a> が <?= $favorite->created_at->strftime('%Y/%m/%d %H:%M:%S') ?> に 気に入りました
      </li>
? }
    </ul>
  </div>
</div>
<script type="text/javascript">
var token = "<?= $c->user ? $c->user->obj->token : '' ?>";
$(function () {
    $("#heart_button").click(fav_handler);
    $("#tweet_button").click(twe_handler);
});
</script>
? }
