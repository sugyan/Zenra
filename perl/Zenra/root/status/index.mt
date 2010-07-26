? extends 'common/base';

? my $status = $c->stash->{status};
? block content => sub {
<div id="content">
  <div class="status">
    <span class="text"><?= $status->text ?></span>
? if ($c->user) {
    <div class="buttons">
      <span class="heart"><img src="/img/heart_gray.png" height="19" width="25" /></span>\
      <span class="tweet"><img src="/img/tweet.png" height="22" width="22" /></span>\
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
        <a href="/user/<?= $favorite->user->screen_name ?>">@<?= $favorite->user->screen_name ?></a> が <?= $favorite->created_at->strftime('%Y/%m/%d %H:%M:%S') ?> に拡散しました
      </li>
? }
    </ul>
  </div>
</div>
? }
