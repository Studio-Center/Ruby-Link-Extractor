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
		@external_links = Array.new

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
		skip = 0

		# define search uri if undefined
		if search_uri == ""
			if @search_uri != ""
				search_uri = @search_uri
				# empty default @search_uri once used
				@search_uri = ""
			else
				# set search uri
				if !@links[@search_index].nil?
					search_uri = @links[@search_index][0]
				else
					# save results and exit
					save_results
					return
				end
				# check for existing link check data
				# check for direct link
				if search_uri[0,5] == "http:" || search_uri[0,6] == "https:"
					# if external link go to next link
					if search_uri.index(@local_domain[0]) == nil
						@external_links.push(search_uri)
						skip = 1	
					end
					# increment search index value
					@search_index += 1
				else
					# check for mailto link
					if search_uri[0,7] == "mailto:" && search_uri[0,4] == "tel:"
						skip = 1
					else
						# check for relative link
						if search_uri[0,2] != "//" && search_uri[0] == "/"
							search_uri[0] = ""
						end
						# define uri string
						if search_uri[0,2] != "//"
							search_uri = "#{@search_domain}#{search_uri}"
						else
							# handle protocol agnotic link requests
							if @search_domain[0,6] == "https:"
								search_uri = "https:#{search_uri}"
							else
								search_uri = "http:#{search_uri}"
							end
						end
					end
					# increment search index value
					@search_index += 1
				end
			end
		end

		# check for existing uri hash index
		if @checked_links[search_uri.to_sym]
			skip = 1
		end

		# run link scan if skip bit is not set
		if skip == 0

			# let user know which uri is currently active
			puts search_uri

			# gather page request response
			response = Net::HTTP.get_response(URI.parse(search_uri))

			# store response page body
			body = response.body

			# store response code
			code = response.code

			# extract all links within page
			links_array = body.scan(/<a.*href=['"]([^"']+)['"]/)

			# update anchors and indirect links to use direct links
			links_array.each { |val|
				if val[0,7] != "mailto:" && val[0,4] != "tel:" && val[0] != "/" && val[0,5] != "http:" && val[0,6] != "https:" && val[0,2] != "//"
					val = "#{search_uri}#{val}"
				end
			}

			# combine found links with links array
			@links.concat(links_array)

			# remove duplicates
			@links.uniq!

			# store results in checked hash
			@checked_links[search_uri.to_sym] = code

		end

		# iterate through found links
		get_links

	end

	def save_results
		# save results
		CSV.open("results.csv", "wb") {|csv| 
			@checked_links.each {|key| 
				csv << key
			}
		}
		# store only unique external link values
		@external_links.uniq!
		# save list of external links
		CSV.open("external-links.csv", "wb") {|csv| 
			@external_links.each do |key|
			   csv << [key]
			end
		}
	end

end

parse_page = LinkScrapper.new
parse_page::get_links