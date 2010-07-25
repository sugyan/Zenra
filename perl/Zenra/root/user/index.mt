? extends 'common/base';

? block title => sub { $c->stash->{screen_name} . ' - ' . super() }

? my $user_info = $c->stash->{user_info};
? block content => sub {
<div class="name"><?= $user_info->{name} ?></div>
<div class="location"><?= $user_info->{location} ?></div>
<div class="url"><?= $user_info->{url} ?></div>
<pre class="description"><?= $user_info->{description} ?></pre>
<ul id="statuses" />
<script type="text/javascript">
$(function () {
    user_timeline("<?= $c->stash->{screen_name} ?>");
});
</script>
? }
