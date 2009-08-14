#/usr/bin/env python
# -*- coding: utf-8 -*-

import base64
import logging
import yaml
import urllib
from django.utils import simplejson
from google.appengine.api import urlfetch
from google.appengine.ext.webapp import RequestHandler


class TwitterHandler(RequestHandler):
    def __init__(self):
        # config.yamlから設定情報を取得
        #     ---
        #     bot:
        #       username: zenra_bot
        #       password: ********
        config_data = yaml.load(open('config.yaml'))
        bot_config = config_data['bot']
        self.auth_header = {
            'Authorization' : 'Basic ' + base64.b64encode(
                '%s:%s' % (bot_config['username'], bot_config['password'])
                )
            }

    def get(self):
        friends   = self.friends()
        followers = self.followers()
        for id in followers:
            if not id in friends:
                logging.debug(id)

    def friends(self):
        url  = 'http://twitter.com/friends/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            return simplejson.loads(result.content)

    def followers(self):
        url  = 'http://twitter.com/followers/ids.json'
        result = urlfetch.fetch(
            url     = url,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)
        if result.status_code == 200:
            return simplejson.loads(result.content)

    def update(self, status):
        url  = 'http://twitter.com/statuses/update.json'
        data = urllib.urlencode({
                'status' : status,
                })
        result = urlfetch.fetch(
            url     = url,
            method  = urlfetch.POST,
            payload = data,
            headers = self.auth_header,
            )
        logging.debug(result.status_code)
        logging.debug(result.content)

