require 'mechanize'
require 'nokogiri'

class Responser<Mechanize
  attr_reader :statuses
  HEADER = {'Accept' => 'text/html','Content-Type' => 'text/html'}

  def start(auth_page, login, password)
    @statuses = {}
    @base_uri = auth_page.sub URI(auth_page).request_uri, ''
    add_auth(auth_page, login, password)
    recursive_search(@base_uri) 
  end

  def filter
    tmp = {}
    self.page.links.map(&:href).compact.uniq.each do |link|
      tmp[@base_uri + link] = nil unless is_exclusion?(link)
    end
    @statuses = tmp.merge(@statuses)
  end

  def is_exclusion?(link)
    link == '#' || link.empty? || link =~ /^(http|https)/ 
  end

  def recursive_search(url)
    @statuses[url] = begin
      get(url, nil, nil, HEADER).code
    rescue Exception => e
      e.message
    end
    proceed = @statuses.select {|k,v| v}.count
    puts "URL: #{url}\nStatus: #{@statuses[url]}\nDone: #{proceed}\nLeft: #{@statuses.count - proceed}"
    puts '============================================================================================'
    filter
    @statuses.each do |link, code|
      recursive_search(link) unless code
    end
  end
end
