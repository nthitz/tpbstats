require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'pg'

def grabData(torrent)
	url = "/torrent/" + torrent['id'] + '/'
	fullURL = 'http://thepiratebay.se' + url
	uri = URI(fullURL)

	puts url
	#res = Net::HTTP.get_response(URI(url))
	headers = {
		'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
		'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
		#'Accept-Encoding' => 'gzip,deflate,sdch',
		'Accept-Language' => 'en-US,en;q=0.8',
		'Cache-Control' => 'no-cache',
		'Connection' => 'keep-alive',
		'Cookie' => 'tpb_showArtist=1; PHPSESSID=a9c441af2472093930e6eab697c6c46c; language=en_EN; __PPU2_CHECK=1; __PPU2_SESSION_0-3=X1413,1362547157,1,1362460757X',
		'Host' => 'thepiratebay.se',
		'Pragma' => 'no-cache',
		'Referer' => 'http://thepiratebay.se/browse/602',
		'User-Agent' => 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.70 Safari/537.17'
	}
	#puts uri
	http = Net::HTTP.new(uri.hostname, uri.port)
	http.open_timeout = 1
	#req = Net::HTTP::Get.new(url,headers)
	#req.open_timeout = 1
	puts 'starting'
	#res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  	#	http.request(req)
	#}
	#http.get(uri.path, headers)
	html = `curl -s -4 #{fullURL}`
	doc = Nokogiri::HTML(html)
	
	#doc = Nokogiri::HTML(File.read('tpb_data/testtorrent2.html'))
	query = 'UPDATE torrent SET category_id='
	cat = doc.css('[title="More from this category"]')
	cat = cat[0]['href']
	puts cat
	user = doc.xpath('.//dd/a[starts-with(@href, "/user/")]')
	user = user[0]['href']
	puts user
	tags = doc.xpath('.//dd/a[starts-with(@href, "/tag/")]');
	puts tags[0].content
	pic = doc.css('[title="picture"]')
	pic = pic[0]['src']
	puts user
	puts pic

end
$conn = PG.connect( dbname: ENV['DBNAME'], host: ENV['DBHOST'], user: ENV['DBUSER'], password: ENV['DBPASS'])
$conn.exec('SELECT tpb_id,title FROM torrent ORDER BY comment_count DESC LIMIT 1') do |result|
	result.each do |row|
		puts row
		row['id'] = row['tpb_id']
		grabData(row)
	end
end
