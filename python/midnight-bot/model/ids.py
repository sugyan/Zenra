#/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db


class IDS(db.Model):
    friend   = db.BooleanProperty()
    follower = db.BooleanProperty()
