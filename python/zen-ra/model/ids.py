#/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db


class IDS(db.Model):
    ids = db.ListProperty(int)
