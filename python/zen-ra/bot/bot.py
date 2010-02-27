#/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
from bot.twitter import TwitBot
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp import RequestHandler
from google.appengine.ext.webapp import WSGIApplication
from google.appengine.ext.webapp.util import run_wsgi_app


class TwitterHandler(RequestHandler):
    def __init__(self):
        twit = TwitBot()
        self.action = {
            'friends'   : twit.friends,
            'followers' : twit.followers,
            'friendship': twit.friendship,
            'update'    : twit.update,
            'zenrize'   : twit.zenrize,
            }

    def get(self):
        action = self.action.get(self.request.get('action'))
        if action:
            logging.debug(action)
            action()
        template_values = {
            'actions' : sorted(self.action.keys()),
            'done'    : self.request.get('action'),
            'path'    : self.request.path,
            }
        path = os.path.join(os.path.dirname(__file__), 'template.html')
        self.response.out.write(template.render(path, template_values))

def main():
    logging.getLogger().setLevel(logging.DEBUG)
    application = WSGIApplication([
            ('/bot/twitter', TwitterHandler),
            ], debug = True)
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
