require 'pry'

class Note
  attr_accessor :guid, :created, :tags, :content
  def initialize()
    @tags = []
    @content = ""
    @deleted = false
  end

  def has_content?(content)
    @content.downcase.split(/\W+/).include?(content)
  end
end

def parse_line(line)
  content = line.scan(/>.*</).first
  content = content ? content[1..-2] : ""
  #binding.pry
  {
    :tag => line.scan(/<[a-z]*>/).first,
    :content => content
    #:content => (content = line.scan(/>.*</).first ? content[1..-2] : "")
  }
end

def create_note
  while (line = gets.chomp) != "</note>"
    input = parse_line(line)
    case input[:tag]
    when "<note>"
      note = Note.new()
      puts "Note created"
    when "<guid>"
      note.guid = input[:content]
      puts "GUID added"
    when "<created>"
      note.created = input[:content]
      puts "Created date set"
    when "<tag>"
      note.tags << input[:content]
      puts "Tag added (#{note.tags.count})"
    when "<content>"
      while (line = gets.strip) != "</content>"
        note.content << line
      end
      puts "Content saved"
    end 
  end
  return note
end

def capture
  notes = []
  line = gets.chomp
  while line == "CREATE"
    notes << create_note
    puts "Note created; what would you like to do next?"
    line = gets.chomp
  end

  notes.each do |note|
    puts note.guid
    puts note.created
    puts note.tags.join(", ")
    puts note.content
  end
end

capture
