? extends 'common/base';

? block title => sub { 'home - ' . super() }

? block content => sub {
<ul id="statuses" />
<script type="text/javascript">
var token = "<?= $c->stash->{token} ?>";
$(function () {
    home_timeline();
});
</script>
? }