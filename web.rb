require 'net/http'
require_relative "pull_file"

# 需要爬取的总页数
total_page = 1
thread_num = 30
# 去要爬取的页面地址
target_url = URI("http://www.wenku8.com/modules/article/articlelist.php")
#账户的cookie
cookie = ""
queue = SizedQueue.new (thread_num + 20)

@total_urls ||= Array.new

1.upto total_page do |page|
    p "scaning #{page} page"

	url = URI("#{target_url}?page=#{page}")

	http = Net::HTTP.new(url.host,url.port)
	headers = {
	    'Cookie' => cookie
	}

	response = http.get(url,headers)
	regex=/http:\/\/www.wenku8.com\/book\/\d{2,5}.htm/

	@total_urls = (@total_urls | response.body.scan(regex).uniq)
end

Thread.new do
	until @total_urls.empty?
		queue.push @total_urls.pop
	end
end

threads = Array.new
thread_num.times do
  threads << Thread.new do
    until queue.empty?
    	begin
    		PullFile.send(:open_html,queue.pop,"//a").each do |i|
					@novel_url = i&.attributes['href']&.content if i&.children&.text == '小说目录'
				end

				PullFile.new(novel_url:@novel_url).pull_file
	      break if queue.size == 0
    	rescue Exception => e
    		p e
    	end
    end
  end
end

threads.each{|thread| thread.join}
