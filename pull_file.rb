require "Nokogiri"
require 'open-uri'

class PullFile

	attr_accessor :novel_name,:novel_url
	
	def initialize(options={})
		@novel_url = options[:novel_url]
	end

	def pull_file

		check_dir novel_name

		pull_urls.each do |pull_url|
			write_novels novels(content(pull_url),title(pull_url)),@novel_name,@title
			write_image images pull_url
		end
	end
	
	private

		def content pull_url
			open_html pull_url,"//div[@id='content']"
		end

		def title pull_url
			@title=open_html(pull_url,"//div[@id='title']").children.text
		end

		def write_novels novels,novel_name,title
			unless File.exist? "#{novel_name}/#{title.delete '/'}.txt"
				file = File.open("#{novel_name}/#{title.delete '/'}.txt","w+")
				file.syswrite novels.join('')
			end
		end

		def write_image images
			images.each do |picture|
				img_file = open(picture) { |f| f.read }
			  file_name = picture.split('/').last
			  open("#{@novel_name}/#{file_name}", "wb") { |f| f.write(img_file) } unless File.exist? "#{@novel_name}/#{file_name}"
			end
		end

		def novels content,title
			novels = Array.new

			content.children.each do |children|
				novels << children.content unless children.content == "\r\n"
			end
			novels.unshift title

			novels.delete_if { |item| item.include?"http://www.wenku8.com" }
		end

		def images pull_url
			images = Array.new
			open_html(pull_url,"//div[@class='divimage']").each do |image|
				images << image&.children[0]&.attributes['href']&.content
			end
			images
		end

		# 获取小说名称
		def novel_name
			@novel_name = open_html(@novel_url,"//div[@id='title']")[0]&.children&.text.delete_suffix('?')
		end

		# 确保目录存在
		def check_dir dir
			Dir.mkdir dir unless Dir.exist? dir
		end

		# 获取各章节地址
		def pull_urls
			pull_urls = Array.new
			open_html(@novel_url,"//table//a").each do |i|
				pull_urls << @novel_url.delete_suffix('index.htm')+i&.attributes['href']&.content
			end
			pull_urls
		end

		def open_html url,xpath=nil
			if xpath
				Nokogiri::HTML(open(url)).xpath(xpath)
			else
				Nokogiri::HTML(open(url))
			end
		end

		def self.open_html url,xpath=nil
			if xpath
				Nokogiri::HTML(open(url)).xpath(xpath)
			else
				Nokogiri::HTML(open(url))
			end
		end
end

