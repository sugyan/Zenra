? extends 'common/base';

? block content => sub {
<h1>全裸的な何か</h1>
?     if ($c->user) {
<a href="/home">home</a>
?     }
<ul>
  <li>Twitter OAuthを使います。
  <li><a href="/login">ログイン</a>するとあなたのfriends_timelineをちょっと改変します。</li>
  <li>勝手に呟いたりは(今のところ)しません。</li>
  <li>まだまだ試行錯誤中</li>
</ul>

<dl>
  <dt>作成者</dt>
    <dd><a href="http://twitter.com/sugyan">sugyan</a></dd>
  <dt>ソースコード</dt>
    <dd><a href="http://github.com/sugyan/Zenra/tree/master/perl/Zenra/">github</a></dd>
</dl>
? }
