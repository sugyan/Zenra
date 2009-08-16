#/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp import WSGIApplication
from google.appengine.ext.webapp import RequestHandler
from google.appengine.ext.webapp.util import run_wsgi_app


class MainHandler(RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'index.html')
        self.response.out.write(template.render(path, {}))


def main():
    logging.getLogger().setLevel(logging.DEBUG)
    application = WSGIApplication([
            ('/', MainHandler),
            ], debug = True)
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
