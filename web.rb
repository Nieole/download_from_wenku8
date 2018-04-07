require 'net/http'
require_relative "pull_file"

# 需要爬取的总页数
total_page = 1
# 去要爬取的页面地址
target_url = URI("http://www.wenku8.com/modules/article/articlelist.php")
#账户的cookie
cookie = ""

1.upto total_page do |page|

	p "now is downloading #{page} page"

	target_url = URI("#{target_url}?page=#{page}")

	http = Net::HTTP.new(target_url.host,target_url.port)
	headers = {
	    'Cookie' => cookie
	}
	
	response = http.get(target_url,headers)
	regex=/http:\/\/www.wenku8.com\/book\/\d{2,5}.htm/

	response.body.scan(regex).uniq.each do |book_url|
		# begin
			# 获取小说目录地址
			PullFile.send(:open_html,book_url,"//a").each do |i|
				@novel_url = i&.attributes['href']&.content if i&.children&.text == '小说目录'
			end

			PullFile.new(novel_url:@novel_url).pull_file
		# rescue Exception => e
		# 	p e
		# end
	end
end
