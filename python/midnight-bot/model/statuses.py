#/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db


class Statuses(db.Model):
    status = db.StringProperty()
