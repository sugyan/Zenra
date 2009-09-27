#/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import logging
import random
import re
import yaml
import urllib
from datetime import datetime
from model.ids import IDS
from model.statuses import Statuses
from django.utils import simplejson
from google.appengine.api import memcache
from google.appengine.api import urlfetch
from google.appengine.ext import db
from zenra import Zenra

ZENRIZE_COUNT = 'zenrize_count'


class TwitBot:
    def __init__(self):
        # config.yamlから設定情報を取得
        #     ---
        #     bot:
        #       username: zenra_bot
        #       password: ********
        config_data = yaml.load(open('../config.yaml'))
        self.bot_config = config_data['bot']
        self.auth_header = {
            'Authorization' : 'Basic ' + base64.b64encode(
                '%s:%s' % (self.bot_config['username'], self.bot_config['password'])
                )
            }

    # 自分のfriendsのデータを更新する
    def friends(self):
        url = 'http://twitter.com/friends/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            keys = ["id:%d" % (id) for id in simplejson.loads(result.content)]
            # 既に登録されているidかどうかをチェックする
            for id in IDS.all().filter('friend =', True):
                key_name = id.key().name()
                # 登録されていれば処理の必要なし
                if key_name in keys:
                    keys.remove(key_name)
                # フォローしている筈だったのが外れている場合
                else:
                    id.friend = False
                    id.put()
            # 新規にフォローすべきidとして登録
            ids = []
            for key in keys:
                id = IDS.get_by_key_name(key)
                if id == None:
                    id = IDS(key_name = key, follower = False)
                id.friend = True
                ids.append(id)
            db.put(ids)

    # 自分のfollowersのデータを更新する
    def followers(self):
        url = 'http://twitter.com/followers/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            keys = ["id:%d" % (id) for id in simplejson.loads(result.content)]
            # 既に登録されているidかどうかをチェックする
            for id in IDS.all().filter('follower =', True):
                key_name = id.key().name()
                # 登録されていれば処理の必要なし
                if key_name in keys:
                    keys.remove(key_name)
                # フォローされている筈だったのが外されている場合
                else:
                    id.follower = False
                    id.put()
            # 新規にフォローされたidとして登録
            ids = []
            for key in keys:
                id = IDS.get_by_key_name(key)
                if id == None:
                    id = IDS(key_name = key, friend = False)
                id.follower = True
                ids.append(id)
            db.put(ids)

    # 管理しているidを全消去する
    def reset(self):
        db.delete(IDS.all())

    # 新たにフォローする
    def create(self):
        # フォローすべきidの抽出
        query = IDS.all()
        query.filter('follower =', True)
        query.filter('friend =',   False)
        ids = query.fetch(100)
        if len(ids) == 0:
            return
        # APIへの送信
        id = random.choice(ids)
        url = 'http://twitter.com/friendships/create/%s.json' % (id.key().name()[3:])
        result = urlfetch.fetch(
            url     = url,
            method  = urlfetch.POST,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            # 内部データの更新
            id.friend = True
            id.put()

    # フォローを外す
    def destroy(self):
        # リムーブすべきidの抽出
        query = IDS.all()
        query.filter('friend =',   True)
        query.filter('follower =', False)
        ids = query.fetch(100)
        if len(ids) == 0:
            return
        # APIへの送信
        id = random.choice(ids)
        url = 'http://twitter.com/friendships/destroy/%s.json' % (id.key().name()[3:])
        result = urlfetch.fetch(
            url     = url,
            method  = urlfetch.POST,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            # 内部データの更新
            id.delete()

    # 何かをつぶやく
    def update(self, status = None, in_reply_to = None):
        count = Statuses.all().count()
        if not status:
            status = random.choice(Statuses.all().fetch(1000)).status
        url  = 'http://twitter.com/statuses/update.json'
        data = urllib.urlencode({
                'status' : status.encode('utf-8'),
                'in_reply_to_status_id' : in_reply_to,
                })
        result = urlfetch.fetch(
            url     = url,
            method  = urlfetch.POST,
            payload = data,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)

    # 発言を拾って全裸にする
    def zenrize(self):
        cache = memcache.decr(ZENRIZE_COUNT)
        if cache:
            logging.debug('count: %d' % cache)
            return

        url = 'http://twitter.com/statuses/friends_timeline.json?count=50'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        if result.status_code == 200:
            statuses = simplejson.loads(result.content)

            # 次の実行時間を決定する
            format = '%a %b %d %H:%M:%S +0000 %Y'
            first = datetime.strptime(statuses[ 0]['created_at'], format)
            last  = datetime.strptime(statuses[-1]['created_at'], format)
            logging.debug('first : %s' % first)
            logging.debug('last  : %s' % last)
            logging.debug(first - last)
            memcache.set(ZENRIZE_COUNT, (first - last).seconds / 60)

            def judge(status):
                # 自分の発言は除く
                if status['user']['screen_name'] == self.bot_config['username']:
                    return False
                # 非公開の発言も除く
                if status['user']['protected']:
                    return False
                # RTっぽい発言も除く
                if re.search('RT[ :].*@\w+', status['text']):
                    return False
                # ハッシュタグっぽいものを含んでいる発言も除く
                if re.search(' #\w+', status['text']):
                    return False
                # それ以外のものはOK
                return True

            # 残ったものからランダムに選択して全裸にする
            candidate = filter(judge, statuses)
            random.shuffle(candidate)
            zenra = Zenra()
            for status in candidate:
                text = zenra.zenrize(status['text']).decode('utf-8')
                # うまく全裸にできたものだけ投稿
                if re.search(u'全裸で', text):
                    logging.debug(text)
                    self.update(status = u'@%s が全裸で言った: %s' % (
                            status['user']['screen_name'],
                            text,
                            ), in_reply_to = status['id'])
                    break
