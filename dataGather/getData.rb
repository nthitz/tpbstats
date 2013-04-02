require 'rubygems'
require 'pg'

def readCategoryFile(category) 
	category.strip!
	filename = "dataGather/categories/"+ category + ".list"
	puts filename
	catFile = File.new(filename,"r")
	while(catItem = catFile.gets)
		catItem.strip!
		query = catItem.gsub(/ /,'.?')
		puts "#{query}"
		res = $conn.exec('SELECT title FROM torrent WHERE title~*\''+query+'\'')
		res.each { |row|
			puts row
		}
		break
	end
	catFile.close
end
$conn = PG.connect( dbname: ENV['DBNAME'], host: ENV['DBHOST'], user: ENV['DBUSER'], password: ENV['DBPASS'])
counter = 1
file = File.new("dataGather/categories.list", "r")
while (line = file.gets)
    puts "#{counter}: #{line}"
    readCategoryFile(line)
    counter = counter + 1
    break
end
file.close

#$conn.exec('DELETE FROM comment')
