<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title><? block title => sub { '全裸的な何か' } ?></title>
    <link rel="stylesheet" type="text/css" media="screen" href="/css/style.css" /> 
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">google.load("jquery", "1.4.2");</script>
    <script type="text/javascript" src="/js/zenra.js"></script>
  </head>
  <body>
    <div id="header">
      <div id="top">
        <a href="/"><img src="/img/logo.png" /></a>
? if ($c->user) {
        <a href="/home">home</a>
? }
      </div>
      <div id="user">
? if ($c->user) {
?     my $screen_name = $c->user->obj->screen_name
<a href="/user/<?= $screen_name ?>">@<?= $screen_name ?></a>としてログイン中
?     if (my $remaining = $c->stash->{remaining}) {
(API残り<?= $remaining ?>回)
?     }
<a href="/logout">ログアウト</a><br />
? } else {
<a href="/login">OAuthでログインする</a><br />
? }
      </div>
    </div>
? block content => '';
  </body>
</html>