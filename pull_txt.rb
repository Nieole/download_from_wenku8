require "Nokogiri"
require 'open-uri'

class PullTxt

	attr_accessor :title,:content,:novel_name,:pull_urls,:pictures
	
	def initialize(options={})
		@pull_urls = options[:pull_urls]
		@novel_name = options[:novel_name]
		@pictures = Array.new
	end

	def pull_txt
		@pull_urls.each do |url|
			get_content Nokogiri::HTML(open(url))
			write_file novels
			write_image
		end
	end

	
	private
		def get_content doc
			doc.xpath("//div").each do |div|
				@content = div if div&.attributes['id']&.value == 'content'

				@title = div.content if div&.attributes['id']&.value == 'title'
			end

			doc.xpath("//div[@class='divimage']").each do |i|
				@pictures << i&.children[0]&.attributes['href']&.content
			end
		end	

		def write_file novels
			file = File.open("#{@novel_name}/#{@title}.txt","w+")
			novel=String.new
			novels.each do |nove|
				novel += "#{nove}\r\n"
			end
			file.syswrite novel
		end

		def write_image
			@pictures.each do |picture|
				img_file = open(picture) { |f| f.read }
			  file_name = picture.split('/').last
			  open("#{@novel_name}/#{file_name}", "wb") { |f| f.write(img_file) }
			end
			@pictures.clear
		end

		def novels
			novels = Array.new

			@content.children.each do |children|
				novels << children.content.strip unless children.content.strip == ""
			end
			novels.unshift @title

			novels.delete_if { |item| item.include?"http://www.wenku8.com" }
		end
end

