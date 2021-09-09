require 'mechanize'
require 'fileutils'
require 'open-uri'

class String
  def truncate(max)
    length > max ? "#{self[0...max]}..." : self
  end
end

p 'Please, provide your auction number:'
@auction_number = gets.chomp
p @auction_number
if @auction_number.length == 10
  FileUtils.mkdir_p 'auctions/'

  mechanize = Mechanize.new
  page = mechanize.get('https://www.allegro.pl/')
  form = page.forms.first
  form['string'] = @auction_number
  page = form.submit

  page.search('div.description').each do |description|
    @description = description.text.strip
  end

  page.search('h1.title').each do |title|
    @auction_name = title.text.strip
  end

  @auction_name = @auction_name.truncate(50).gsub('.', '')[0...-5]
  FileUtils.mkdir_p "auctions/#{@auction_name}"
  File.open("auctions/#{@auction_name}/#{@auction_name}.txt", 'w') { |file| file.write(@description) }
  File.open("auctions/#{@auction_name}/#{@auction_number}", 'w') { |file| file.write('') }

  FileUtils.mkdir_p "auctions/#{@auction_name}/images"
  @image_number = 1
  page.search('div.description img').each do |img|
    p "Saving image nr #{@image_number}"
    File.open("auctions/#{@auction_name}/images/#{@image_number}.jpg", 'wb') do |f|
      image_name = mechanize.resolve(img['src'])
      f.print open(image_name).read
    end
    @image_number += 1
  end

  p 'Done!'
  p @auction_name
else
  p 'Your auction number should contain 10 digits!'
end
