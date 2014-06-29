require 'net/http'
require 'csv'

# default search domain
SEARCH_DOMAIN = "http://virginiabeachwebdevelopment.com/"

class LinkScrapper
	attr_reader :links

	def initialize

		# init link store hashes
		@search_index = 0
		@links = Array.new
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

	# gather link data
	def get_links

		search_uri = ""

		# define search uri if undefined
		if search_uri == ""
			if @search_uri != ""
				search_uri = @search_uri
				# empty default @search_uri once used
				@search_uri = ""
			else
				# set search uri
				search_uri = @links[@search_index][0]
				# check for existing link check data
				# check for direct link
				if search_uri.index(/(http:|https:)/) != nil
					# if external link go to next link
					if search_uri.index(@local_domain[0]) == nil
						@search_index += 1
						return search_uri
					else
						# increment search index value
						@search_index += 1
					end
				else
					search_uri = "#{@search_domain}#{search_uri}"
					# increment search index value
					@search_index += 1
				end
			end
		end

		# gather page request response
		response = Net::HTTP.get_response(URI.parse(search_uri))

		# store response page body
		body = response.body

		# store response code
		code = response.code

		# extract all links within page
		links_array = body.scan(/<a.*href=['"]([^"']+)['"]/)

		# combine found links with links array
		@links.concat(links_array)

		# remove duplicates
		@links.uniq!

		# store results in checked hash
		@checked_links[search_uri.to_sym] = code

		# iterate through found links
		get_links

	end

	def save_results
		CSV.open("results.csv", "wb") {|csv| 
			@checked_links.each {|key| 
				csv << key
			}
		}
	end

end

parse_page = LinkScrapper.new
parse_page::get_links
parse_page::save_results