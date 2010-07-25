? extends 'common/base';

? block title => sub { $c->stash->{screen_name} . ' - ' . super() }

? my $user_info = $c->stash->{user_info};
? block content => sub {
<div id="name"></div>
<div id="location"></div>
<div id="url"></div>
<pre id="description"></pre>
<ul id="statuses" />
<script type="text/javascript">
var token = "<?= $c->stash->{token} ?>";
$(function () {
    user_timeline("<?= $c->stash->{screen_name} ?>");
});
</script>
? }
