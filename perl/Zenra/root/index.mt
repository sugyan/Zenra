? extends 'common/base';

? block content => sub {
? if ($c->user) {
<?= $c->user->obj->screen_name ?> <a href="/logout">ログアウト</a><br />
? } else {
<a href="/login">ログイン</a><br />
? }

? }
