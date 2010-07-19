<ul class="statuses">
? for my $status (@{ $c->stash->{statuses} }) {
?     my $screen_name = $status->{user}{screen_name} || $status->{screen_name};
<li class="status<?= $status->{no_zenra} ? ' no_zenra' : '' ?>">
  <span class="profile_image">
    <a href="/user/<?= $screen_name ?>">
      <img src="<?= $status->{user}{profile_image_url} || $status->{profile_image} ?>" height="48" width="48" />
    </a>
  </span>
  <span class="body">
    <div class="screen_name">
      <a href="/user/<?= $screen_name ?>">@<?= $screen_name ?></a>
    </div>
    <?= $status->{text} ?>
  </span>
</li>
? }
</ul>