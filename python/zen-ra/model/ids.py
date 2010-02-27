#/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db


class IDS(db.Model):
    friends   = db.TextProperty()
    followers = db.TextProperty()

    @classmethod
    def get(cls):
        return IDS.get_or_insert(
            key_name  = 'unique',
            friends   = '',
            followers = '',
            )
