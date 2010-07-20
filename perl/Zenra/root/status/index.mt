? extends 'common/base';

? my $status = $c->stash->{status};
? block content => sub {
<div id="content">
  <div class="status">
    <span class="text"><?= $status->text ?></span>
    <span class="meta"><?= $status->created_at->strftime('%Y/%m/%d %H:%M:%S') ?></span>
    <div class="user_info">
      <div class="icon"><img src="<?= $status->profile_image ?>" /></div>
      <div class="screen_name">
        <a href="/user/<?= $status->screen_name ?>"><?= $status->screen_name ?></a>
      </div>
      <div class="name"><?= $status->name ?></div>
    </div>
  </div>
</div>
? }
