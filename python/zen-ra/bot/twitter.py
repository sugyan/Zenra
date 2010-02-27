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
            ids = IDS.get()
            ids.friends = result.content
            ids.put()

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
            ids = IDS.get()
            ids.followers = result.content
            ids.put()

    # friends, followersの情報から、follow or unfollowする
    def friendship(self):
        ids = IDS.get()
        friends   = set(simplejson.loads(ids.friends))
        followers = set(simplejson.loads(ids.followers))
        should_follow   = list(followers - friends)
        should_unfollow = list(friends - followers)
        random.shuffle(should_follow)
        random.shuffle(should_unfollow)
        logging.debug("should follow: %d" % len(should_follow))
        logging.debug("should unfollow: %d" % len(should_unfollow))
        # 繰り返し挑戦するので失敗してもタイムアウトになっても気にしない
        while len(should_follow) > 0 or len(should_unfollow) > 0:
            if len(should_follow) > 0:
                url = 'http://twitter.com/friendships/create/%s.json' % should_follow.pop()
                logging.debug(url)
                result = urlfetch.fetch(
                    url     = url,
                    method  = urlfetch.POST,
                    headers = self.auth_header,
                    )
                if result.status_code != 200:
                    logging.warn(result.content)
            if len(should_unfollow) > 0:
                url = 'http://twitter.com/friendships/destroy/%s.json' % should_unfollow.pop()
                result = urlfetch.fetch(
                    url     = url,
                    method  = urlfetch.POST,
                    headers = self.auth_header,
                    )
                if result.status_code != 200:
                    logging.warn(result.content)

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

        url = 'http://twitter.com/statuses/friends_timeline.json?count=150'
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
            memcache.set(ZENRIZE_COUNT, (first - last).seconds * 2 / 60)

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
                if re.search(u'[#＃]\w+', status['text']):
                    return False
                # 既に「全裸で」が含まれている発言も除く
                if re.search(u'全裸で', status['text']):
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
        # 400が返ってきたときは10分間黙るようにしてみる
        elif result.status_code == 400:
            memcache.set(ZENRIZE_COUNT, 10)
