require 'net/http'
require_relative "pull_txt"

1.upto 116 do |page|
	u = "http://www.wenku8.com/modules/article/articlelist.php?page=#{page}"

	u = URI(u)

	cookie = ""

	http = Net::HTTP.new(u.host,u.port)
	headers = {
	    'Cookie'=> cookie
	}

	doc = http.get(u,headers)
	regex=/http:\/\/www.wenku8.com\/book\/\d{3,5}.htm/

	doc.body.scan(regex).uniq.each do |book_url|
		begin
			Nokogiri::HTML(open(book_url)).xpath("//a").each do |i|
				@url = i&.attributes['href']&.content if i&.children&.text == '小说目录'
			end

			@novel_name = Nokogiri::HTML(open(@url)).xpath("//div[@id='title']")[0].children.text.delete_suffix('?')
			@pull_urls = Array.new
			Nokogiri::HTML(open(@url)).xpath("//table//a").each do |i|
				@pull_urls << @url.delete_suffix('index.htm')+i&.attributes['href']&.content
			end

			Dir.mkdir @novel_name unless Dir.exist? @novel_name

			PullTxt.new(novel_name:@novel_name,pull_urls:@pull_urls).pull_txt
		rescue Exception => e
			p e
		end
	end
end
