# Responser
This script for scraping all status codes from all links on a site.

Execute:
r = Responser.new
r.add_auth('http://example.com/login', 'user', 'password')
r.start('http://example.com/start')

or without auth

r = Responser.new
r.start('http://0.0.0.0:3000/')
