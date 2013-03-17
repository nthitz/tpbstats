require 'rubygems'
require 'pg'

$conn = PG.connect( dbname: ENV['DBNAME'], host: ENV['DBHOST'], user: ENV['DBUSER'], password: ENV['DBPASS'])
$conn.exec('SELECT tpb_id FROM torrent WHERE comment_count IS NULL') do |result|
	puts result
	result.each do |row|
		puts row
	end
end