#/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from bot.twitter import TwitBot
from google.appengine.ext.webapp import RequestHandler
from google.appengine.ext.webapp import WSGIApplication
from google.appengine.ext.webapp.util import run_wsgi_app


class TwitterHandler(RequestHandler):
    def __init__(self):
        twit = TwitBot()
        self.action = {
            'friends'   : twit.friends,
            'followers' : twit.followers,
            'create'    : twit.create,
            'destroy'   : twit.destroy,
            'update'    : twit.update,
            'zenrize'   : twit.zenrize,
            }

    def get(self):
        action = self.action.get(self.request.get('action'))
        if action:
            logging.debug(action)
            action()


def main():
    logging.getLogger().setLevel(logging.DEBUG)
    application = WSGIApplication([
            ('/bot/twitter', TwitterHandler),
            ], debug = True)
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
