? extends 'common/base';

? block title => sub { 'home - ' . super() }

? block content => sub {
?     for my $status (@{ $c->stash->{statuses} }) {
<div class="status">
  <div class="profile_image"><img src="<?= $status->{user}{profile_image_url} || $status->{profile_image} ?>" height="48" width="48" /></div>
  <div class="text">
    <div class="screen_name">@<?= $status->{user}{screen_name} || $status->{screen_name} ?></div>
    <?= $status->{text} ?>
  </div>
</div>
?     }
? }
