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

    def friends(self):
        url = 'http://twitter.com/friends/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            IDS(
                key_name = 'friends',
                ids      = simplejson.loads(result.content),
                ).put()

    def followers(self):
        url = 'http://twitter.com/followers/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            IDS(
                key_name = 'followers',
                ids      = simplejson.loads(result.content),
                ).put()

    def create(self):
        friends   = IDS.get_by_key_name('friends')
        followers = IDS.get_by_key_name('followers')
        logging.debug(friends.ids)
        logging.debug(followers.ids)
        for id in followers.ids:
            if id not in friends.ids:
                url = 'http://twitter.com/friendships/create/%d.json' % (id,)
                result = urlfetch.fetch(
                    url     = url,
                    method  = urlfetch.POST,
                    headers = self.auth_header,
                    )
                logging.debug(result.status_code)
                logging.debug(result.content)
                return

    def destroy(self):
        friends   = IDS.get_by_key_name('friends')
        followers = IDS.get_by_key_name('followers')
        logging.debug(friends.ids)
        logging.debug(followers.ids)
        for id in friends.ids:
            if id not in followers.ids:
                url = 'http://twitter.com/friendships/destroy/%d.json' % (id,)
                result = urlfetch.fetch(
                    url     = url,
                    method  = urlfetch.POST,
                    headers = self.auth_header,
                    )
                logging.debug(result.status_code)
                logging.debug(result.content)
                return

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
