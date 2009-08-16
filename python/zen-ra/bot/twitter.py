#/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import logging
import random
import yaml
import urllib
from model.ids import IDS
from model.statuses import Statuses
from django.utils import simplejson
from google.appengine.api import urlfetch
from google.appengine.ext import db
from zenra import Zenra


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
                    id.friend = None
                    id.put()
            # 新規にフォローすべきidとして登録
            ids = []
            for key in keys:
                id = IDS.get_by_key_name(key)
                if id == None:
                    id = IDS(key_name = key)
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
                    id.follower = None
                    id.put()
            # 新規にフォローされたidとして登録
            ids = []
            for key in keys:
                id = IDS.get_by_key_name(key)
                if id == None:
                    id = IDS(key_name = key)
                id.follower = True
                ids.append(id)
            db.put(ids)

    def reset(self):
        db.delete(IDS.all())

    def create(self):
        # フォローすべきidの抽出
        query = IDS.all()
        query.filter('follower =', True)
        query.filter('friend =',   None)
        id = query.get()
        if id:
            # 内部データの更新
            id.friend = True
            id.put()
            # APIへの送信
            url = 'http://twitter.com/friendships/create/%s.json' % (id.key().name()[3:])
            result = urlfetch.fetch(
                url     = url,
                method  = urlfetch.POST,
                headers = self.auth_header,
                )
            logging.debug(result.status_code)
            logging.debug(result.content)

    def destroy(self):
        # リムーブすべきidの抽出
        query = IDS.all()
        query.filter('friend =',   True)
        query.filter('follower =', None)
        id = query.get()
        if id:
            # 内部データの更新
            id.delete()
            # APIへの送信
            url = 'http://twitter.com/friendships/destroy/%s.json' % (id.key().name()[3:])
            result = urlfetch.fetch(
                url     = url,
                method  = urlfetch.POST,
                headers = self.auth_header,
                )
            logging.debug(result.status_code)
            logging.debug(result.content)

    def update(self, status = None):
        count = Statuses.all().count()
        if not status:
            status = random.choice(Statuses.all().fetch(1000)).status
        url  = 'http://twitter.com/statuses/update.json'
        data = urllib.urlencode({
                'status' : status.encode('utf-8'),
                })
        result = urlfetch.fetch(
            url     = url,
            method  = urlfetch.POST,
            payload = data,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)

    def zenrize(self):
        url = 'http://twitter.com/statuses/friends_timeline.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            statuses = simplejson.loads(result.content)
            # 自分の発言は除く
            for status in statuses:
                if status['user']['screen_name'] == self.bot_config['username']:
                    statuses.remove(status)
            status = random.choice(statuses)
            text = status['text']
            self.update(status = u'@%s が全裸で言った: %s' % (
                    status['user']['screen_name'],
                    Zenra().zenrize(text).decode('utf-8'),
                    ))
