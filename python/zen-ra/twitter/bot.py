#/usr/bin/env python
# -*- coding: utf-8 -*-

import yaml
from google.appengine.ext.webapp import RequestHandler

class TwitterHandler(RequestHandler):
    def get(self):
        # config.yamlから設定情報を取得
        config = yaml.load(open('config.yaml'))

