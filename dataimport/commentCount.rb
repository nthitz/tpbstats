require 'rubygems'
require 'pg'

$conn = PG.connect( dbname: ENV['DBNAME'], host: ENV['DBHOST'], user: ENV['DBUSER'], password: ENV['DBPASS'])
$conn.exec('SELECT tpb_id FROM torrent WHERE comment_count IS NULL') do |result|
	puts result
	result.each do |row|
		$conn.exec('SELECT COUNT(*) as count FROM comment WHERE tpb_id=$1',[row['tpb_id']]) do |countResult|
			countResult.each do |countRow|
				puts row['tpb_id'] + " " + countRow['count']
				$conn.exec('UPDATE torrent SET comment_count=$1 WHERE tpb_id=$2',[countRow['count'],row['tpb_id']])
			end
		end
	end
end