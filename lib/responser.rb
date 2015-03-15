require 'mechanize'
require 'nokogiri'

class Responser<Mechanize
  attr_reader :links

  def start(link)
    require 'pry';binding.pry
    @links = get(link).links.map(&:href)
  end

  def open(link)
  end

  def search
  end
end


r = Responser.new
r.add_auth('http://   /users/sign_in', 'admin', 'changeme')
r.get('http://   /virtual_machines.json')
r.start('http://   /virtual_machines')
require 'pry';binding.pry