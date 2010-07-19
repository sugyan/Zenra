? extends 'common/base';

? my $status = $c->stash->{status};
? block content => sub {
<div id="status">
  <img src="<?= $status->profile_image ?>" />
  <span class="screen_name">@<?= $status->screen_name ?></span>
  <span class="content"><?= $status->text ?></span>
</div>
? }
