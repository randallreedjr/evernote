require 'pry'

class Note
  attr_accessor :guid, :created, :tags, :content, :deleted
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
  note = Note.new()
  while (line = gets.chomp) != "</note>"
    input = parse_line(line)
    case input[:tag]
    when "<note>"
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

def delete_note(notes)
  guid = gets.chomp
  note_to_delete = find_note(notes, guid)
  if note_to_delete
    note_to_delete.deleted = true
  end
end

def find_note(notes, guid)
  notes.detect {|note| note.guid == guid}
end

def update_note(notes)
  note = Note.new()
  while (line = gets.chomp) != "</note>"
    input = parse_line(line)
    case input[:tag]
    when "<note>"
    when "<guid>"
      guid = input[:content]
      note = find_note(notes, guid)
      #reset aggregated values
      note.tags = []
      note.content = ""
      puts "Note found"
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

def search_notes(notes)
  search_term = gets.chomp
  if search_term.start_with?("tag:")
    if search_term.end_with?("*")
      tag_prefix_search(notes, search_term.sub("tag:","")[0..-2])
    else
      tag_exact_search(notes, search_term.sub("tag:",""))
    end
  elsif search_term.start_with?("created:")
    created_date_search(notes, search_term.sub("created:",""))
  elsif search_term.end_with?("*")
    prefix_search(notes, search_term[0..-2])
  else
    exact_search(notes, search_term)
  end
end

#make these class methods, make notes a class variable
def tag_prefix_search(notes, search_term)
  puts "Search for tags starting with #{search_term}"
end

def tag_exact_search(notes, search_term)
  puts "Search for tags matching #{search_term}"
end

def created_date_search(notes, search_term)
  puts "Search for notes created after #{search_term}"
end

def prefix_search(notes, search_term)
  puts "Search for notes with words starting with #{search_term}"
end

def exact_search(notes, search_term)
  puts "Search for notes with the word #{search_term}"
end

def print_notes(notes)
  notes.each do |note|
    puts note.guid
    puts "Deleted: #{note.deleted}"
    puts note.created
    puts note.tags.join(", ")
    puts note.content
  end
end

def capture
  notes = []
  puts "Enter command"
  while line = gets.chomp
    case line
    when "CREATE"
      notes << create_note
      puts "Note created; what would you like to do next?"
    when "DELETE"
      delete_note(notes)
    when "UPDATE"
      update_note(notes)
    when "SEARCH"
      search_notes(notes)
    else
      break
    end
  end

  print_notes(notes)
end

capture
