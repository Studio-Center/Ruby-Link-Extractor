require 'net/http'

# default search domain
SEARCH_DOMAIN = "http://virginiabeachwebdevelopment.com/"

class LinkScrapper
	attr_reader :links

	def initialize

		# init link store hashes
		@links = Hash.new
		@checked_links = Hash.new
		@error_links = Hash.new

		# gather search domain
		puts "Please enter a domain to search: (Default: #{SEARCH_DOMAIN})"
		@search_domain = gets.chomp

		# override with default domain if entry is left empty
		@search_domain = SEARCH_DOMAIN if @search_domain == ""

		# get and store local domain string
		@local_domain = @search_domain.match(/\w+\.\w+(?=\/|\s|$)/)

		# configure initial search uri
		@search_uri = @search_domain

	end

	def get_links

		# gather page request response
		response = Net::HTTP.get_response(URI.parse(@search_uri))

		# store response page body
		body = response.body

		# store response code
		code = response.code

		@links = body.scan(/<a.*href=['"]([^"']+)['"]/)

		puts @links

	end

end

parse_page = LinkScrapper.new
parse_page::get_links