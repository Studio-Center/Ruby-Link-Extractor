#!/usr/bin/env ruby
require_relative 'lib/link_scrapper'

settings = {
            domain: 'http://virginiabeachwebdevelopment.com/',
            verbose: true,
            results: 'csv'
          }

LinkScrapper.new(settings)
