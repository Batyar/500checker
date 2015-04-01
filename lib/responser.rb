require 'mechanize'
require 'nokogiri'

class Responser<Mechanize
  attr_reader :statuses
  HEADER = {'Accept' => 'text/html','Content-Type' => 'text/html'}

  def start(start_page)
    @statuses = {}
    path = URI(start_page).request_uri
    @base_uri = path == '/' ? start_page : start_page.sub(path, '')
    get start_page
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
    link == '#' || link.empty? || link =~ /^(http|https)/
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