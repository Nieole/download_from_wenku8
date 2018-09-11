require_relative "pull_file"

# 需要爬取的总页数
total_page = 2455
thread_num = 30
dir_prefix = "novel"
queue = SizedQueue.new (thread_num + 20)

@total_urls ||= Array.new

1.upto total_page do |page|
  @total_urls << "https://www.wenku8.net/book/#{page}.htm"
end

p "start downing total page : #{@total_urls.size}"

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
