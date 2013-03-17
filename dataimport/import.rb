require 'rubygems'
require 'libxml'
require 'pg'
include LibXML
class PostCallbacks
  include XML::SaxParser::Callbacks

  @newTorrent = Hash.new()
  @lastNodeName = ""
  @parsingComments = false
  @curComments = Array.new()
  @curComment = Hash.new()
  
  def initialize
	  @baseQuery = "INSERT INTO torrent (tpb_id, title, magnet, size, seeders, leechers, uploaded, nfo, upvotes, downvotes) VALUES"
	  @curQuery = ""
	  @numQueried = 0
	  @numToQueue = 15
	  @torrentValueStr = "";
	  @commentValueStr = ""
	  @commentValueArray = []
  	  @torrentValueArray = []
  	  @numCommentsQueued = 0
  end

  def on_start_element(element, attributes)

    if element == 'torrent'
    	@newTorrent = {}
    elsif element == 'comments'
    	@parsingComments = true
    	@curComments = []
    elsif element == 'comment'
    	@curComment = {}
   	end
    @lastNodeName = element
   
  end
  
  def on_end_element(element)
	if element == 'torrent'
		if @numQueried == 0
			puts 'first'
			@torrentValueStr = ""
			@torrentValueArray = []
			@commentValueStr = ""
			@commentValueArray = []
			@curQuery = @baseQuery
			@numCommentsQueued = 0
		end
		@newTorrent['comments'] = @curComments
		#sputs @newTorrent
		if !defined?(@newTorrent) || !defined?(@newTorrent['title'])
			puts 'rtn'
			return
		end
 		puts (@newTorrent['title'] or "no title") + ' '  +@newTorrent['comments'].length.to_s
		@torrentValueArray << @newTorrent['id']
		@torrentValueArray << @newTorrent['title']
		@torrentValueArray << @newTorrent['magnet']
		@torrentValueArray << @newTorrent['size']
		@torrentValueArray << @newTorrent['seeders']
		@torrentValueArray << @newTorrent['leechers']
		@torrentValueArray << @newTorrent['uploaded']
		@torrentValueArray << @newTorrent['nfo']
		@torrentValueArray << @newTorrent['up']
		@torrentValueArray << @newTorrent['down']
		#torrentID = $conn.exec('($1, $2, $3, $4, $5, $6, $7, $8)',
		#	[@newTorrent['id'], @newTorrent['title'], @newTorrent['magnet'],
		#	@newTorrent['size'], @newTorrent['seeders'], @newTorrent['leechers'],
		#	@newTorrent['uploaded'], @newTorrent['nfo']]);
		#puts torrentID[0]
		numVars = 10
		@torrentValueStr <<" ($" + (@numQueried * numVars + 1).to_s + ", $"  + (@numQueried * numVars + 2).to_s + ", $" + (@numQueried * numVars + 3).to_s + ", $" 			 + (@numQueried * numVars + 4).to_s + ", $" + (@numQueried * numVars + 5).to_s + ", $" 			 			+ (@numQueried * numVars + 6).to_s + ", $" + (@numQueried * numVars + 7).to_s + ", $" 			+ (@numQueried * numVars + 8).to_s + ", $" + (@numQueried * numVars + 9).to_s + ", $" 			+ (@numQueried * numVars + 10).to_s + ")"

				
		if @newTorrent['comments'].length > 0
			for commentIndex in 0..@newTorrent['comments'].length - 1
				globalCommentIndex = @numCommentsQueued
				@commentValueStr << " ($" + (globalCommentIndex * 3 + 1).to_s + ", $" + (globalCommentIndex * 3 + 2).to_s + ", $" + (globalCommentIndex * 3 + 3).to_s + ")"
				if commentIndex != @newTorrent['comments'].length - 1 || @numQueried != @numToQueue - 1
					@commentValueStr << ","
				end
				@commentValueArray << @newTorrent['id']
				comment = @newTorrent['comments'][commentIndex]
				@commentValueArray << comment['when']
				@commentValueArray << comment['what']
				@numCommentsQueued += 1
			end

#			$conn.exec('INSERT INTO comment (torrent_id, posted, msg) VALUES' + valueStr, valueArray)
		end
		@numQueried += 1
		if @numQueried == @numToQueue
			#puts @torrentValueArray
			#puts @commentValueStr
			#puts @commentValueArray
			$conn.exec(@baseQuery + @torrentValueStr, @torrentValueArray)
			@commentValueStr = @commentValueStr.gsub(/[,]+$/, '')
			if @commentValueArray.length != 0
				$conn.exec('INSERT INTO comment (tpb_id, posted, msg) VALUES' + @commentValueStr, @commentValueArray)
			end
			@numQueried = 0
		else
			@torrentValueStr += ","
		end
	elsif element == 'comments'
		@parsingComments = false
	elsif element == 'comment'
		@curComments << @curComment
	elsif element == 'archive'
		if @numQueried != 0
			@torrentValueStr = @torrentValueStr.gsub(/[,]+$/, '')
			$conn.exec(@baseQuery + @torrentValueStr, @torrentValueArray)
			@commentValueStr = @commentValueStr.gsub(/[,]+$/, '')
			if @commentValueArray.length != 0
				$conn.exec('INSERT INTO comment (tpb_id, posted, msg) VALUES' + @commentValueStr, @commentValueArray)
			end
		end
	end
  end
  def on_characters(chars)
=begin
if(t === "\n" || t === "\n\n") {
	  	return;
	  }
//		  console.log(lastNodeName + " " + t);
	  	if(!parsingComments) {
		  newTorrent[lastNodeName] = t;
		} else {
		  curComment[lastNodeName] = t;
		}
=end
	if chars == "\n"
		return
	end
	if ! @parsingComments
		if !@newTorrent.has_key?(@lastNodeName) 
			@newTorrent[@lastNodeName] = ""
		end
		@newTorrent[@lastNodeName] += chars
	else
		if !@curComment.has_key?(@lastNodeName) 
			@curComment[@lastNodeName] = ""
		end

		@curComment[@lastNodeName] += chars
		if @lastNodeName == 'when'
			@curComment[@lastNodeName] = chars
		end
	end

  end
end

=begin
var newTorrent = {};
var lastNodeName = null;
var parsingComments = false;
var curComments = [];
var curComment = null;
=end

$conn = PG.connect( dbname: ENV['DBNAME'], host: ENV['DBHOST'], user: ENV['DBUSER'], password: ENV['DBPASS'])
$conn.exec('DELETE FROM comment')
$conn.exec('DELETE FROM torrent')
parser = XML::SaxParser.file("tpb_data/rich.corrected.xml")
parser.callbacks = PostCallbacks.new
parser.parse