# require 'net/http'
require_relative "pull_file"

# 需要爬取的总页数
total_page = 2455
thread_num = 30
dir_prefix = "novel"
# 去要爬取的页面地址
# target_url = URI("http://www.wenku8.com/modules/article/articlelist.php")
#账户的cookie
# cookie = "Hm_lvt_d72896ddbf8d27c750e3b365ea2fc902=1536315965; UM_distinctid=165b3930db00-08746c98e81ad5-9393265-130980-165b3930db2104; PHPSESSID=6cvug6j9khqsi27g13tup0reh4hceno3; jieqiUserInfo=jieqiUserId%3D240283%2CjieqiUserName%3Dnicoer%2CjieqiUserGroup%3D3%2CjieqiUserVip%3D0%2CjieqiUserName_un%3Dnicoer%2CjieqiUserHonor_un%3D%26%23x65B0%3B%26%23x624B%3B%26%23x4E0A%3B%26%23x8DEF%3B%2CjieqiUserGroupName_un%3D%26%23x666E%3B%26%23x901A%3B%26%23x4F1A%3B%26%23x5458%3B%2CjieqiUserLogin%3D1536647575%2CjieqiUserPassword%3Db4bef0b7fe2429fcfc91a94a7b126f61; jieqiVisitInfo=jieqiUserLogin%3D1536647575%2CjieqiUserId%3D240283; CNZZDATA1309966=cnzz_eid%3D1249140960-1536311755-%26ntime%3D1536643531; CNZZDATA1259916661=677667521-1536310826-%7C1536643170; Hm_lpvt_d72896ddbf8d27c750e3b365ea2fc902=1536647601"
queue = SizedQueue.new (thread_num + 20)

@total_urls ||= Array.new

1.upto total_page do |page|
  @total_urls << "https://www.wenku8.net/book/#{page}.htm"
end

# 1.upto total_page do |page|
#   p "scaning #{page} page"

#   url = URI("#{target_url}?page=#{page}")

#   http = Net::HTTP.new(url.host, url.port)
#   headers = {
#       'Cookie' => cookie
#   }

#   response = http.get(url, headers)
#   regex = /http:\/\/www.wenku8.com\/book\/\d{2,5}.htm/

#   @total_urls = (@total_urls | response.body.scan(regex).uniq)
# end

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
        PullFile.new(novel_url: queue.pop, dir_prefix: dir_prefix).pull_file
      rescue Exception => e
        p e
      end
    end
  end
end

threads.each {|thread| thread.join}
