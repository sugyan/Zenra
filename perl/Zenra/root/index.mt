? extends 'common/base';

? block content => sub {
<a href="/zenrize">全裸的な何か</a><br />
? if ($c->user) {
<?= $c->user->obj->screen_name ?> <a href="/logout">ログアウト</a><br />
? } else {
<a href="/login">ログイン</a><br />
? }

? }
