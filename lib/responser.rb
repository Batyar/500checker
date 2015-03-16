require 'mechanize'
require 'nokogiri'

class Responser<Mechanize
  attr_reader :statuses
  HEADER = {'Accept' => 'text/html','Content-Type' => 'text/html'}

  def start(auth_page, login, password)
    @statuses = {}
    path = URI(auth_page).request_uri
    @base_uri = path == '/' ? auth_page : auth_page.sub(path, '')
    add_auth(auth_page, login, password)
    recursive_search(@base_uri) 
  end

  def filter
    tmp = {}
    if defined? self.page.links
      self.page.links.map(&:href).compact.uniq.each do |link|
        tmp[@base_uri + link] = nil unless is_exclusion?(link)
      end
      @statuses = tmp.merge(@statuses)
    end
  end

  def is_exclusion?(link)
    link == '#' || link.empty? || link =~ /^(http|https)/ 
  end

  def write_to_log(message)
    ::File.open("./log", "a") { |f| f << message }
  end

  def recursive_search(url)
    @statuses[url] = begin
      get(url, nil, nil, HEADER).code
    rescue Exception => e
      e.message
    end
    proceed = @statuses.select {|k,v| v}.count
    write_to_log "URL: #{url}\nStatus: #{@statuses[url]}\nDone: #{proceed}\nTotal: #{@statuses.count}"
    write_to_log "\n===============================================================================\n"
    filter
    @statuses.each do |link, code|
      recursive_search(link) unless code
    end
  end
end

Responser.new.start('http://0.0.0.0:3000/users/sign_in','admin','changeme')