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
    search
  end

  private

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
    link == '#' || link.empty? || link =~ /^(http|https)/ || link =~ /\/logs\//
  end

  def write_to_log(message)
    ::File.open("./log", "a") { |f| f << message }
  end

  def get_status(url)
    @statuses[url] = begin
      get(url, nil, nil, HEADER).code
    rescue Exception => e
      e.message
    end
    filter
  end

  def search
    get_status(@base_uri) if @statuses.empty?
    while @statuses.values.include?(nil) do
      url = @statuses.key(nil)
      get_status(url)
      proceed = @statuses.select {|k,v| v}.count
      write_to_log "URL: #{url}\nStatus: #{@statuses[url]}\nDone: #{proceed}\nTotal: #{@statuses.count}"
      write_to_log "\n===============================================================================\n"
    end
  end
end

Responser.new.start('http://makemeup.lviv.co.vu',nil,nil)