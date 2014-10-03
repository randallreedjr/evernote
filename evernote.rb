#require 'pry'

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
      #puts "Note created"
    when "<guid>"
      note.guid = input[:content]
      #puts "GUID added"
    when "<created>"
      note.created = input[:content]
      #puts "Created date set"
    when "<tag>"
      note.tags << input[:content]
      #puts "Tag added (#{note.tags.count})"
    when "<content>"
      while (line = gets.strip) != "</content>"
        note.content << line + "\n"
      end
      #puts "Content saved"
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
      #puts "Note found"
    when "<created>"
      note.created = input[:content]
      #puts "Created date set"
    when "<tag>"
      note.tags << input[:content]
      #puts "Tag added (#{note.tags.count})"
    when "<content>"
      while (line = gets.strip) != "</content>"
        note.content << line + "\n"
      end
      #puts "Content saved"
    end 
  end
  return note
end

def search_notes(notes)
  search_term = gets.chomp
  if search_term.start_with?("tag:")
    if search_term.end_with?("*")
      puts tag_prefix_search(notes, search_term.sub("tag:","")[0..-2])
    else
      puts tag_exact_search(notes, search_term.sub("tag:",""))
    end
  elsif search_term.start_with?("created:")
    puts created_date_search(notes, search_term.sub("created:",""))
  elsif search_term.end_with?("*")
    puts prefix_search(notes, search_term[0..-2])
  else
    results = []
    possibles = search_term.split(/\W+/).collect do |term|
      exact_search(notes, term)
    end
    possibles.each do |matches_for_term|
      if results == []
        results = matches_for_term
      else
        results = results & matches_for_term
      end
    end
    puts results.flatten.sort_by{|note| note.created}.collect {|match| match.guid}.join(",")
  end
end

#make these class methods, make notes a class variable
def tag_prefix_search(notes, search_term)
  "Search for tags starting with #{search_term}"
end

def tag_exact_search(notes, search_term)
  "Search for tags matching #{search_term}"
end

def created_date_search(notes, search_term)
  "Search for notes created after #{search_term}"
end

def prefix_search(notes, search_term)
  "Search for notes with words starting with #{search_term}"
end

def exact_search(notes, search_term)
  #binding.pry
  matches = notes.select {|note| note.has_content?(search_term)}
  # if matches.any?
  #   matches.sort_by{|note| note.created}.collect {|match| match.guid}
  # else
  #   []
  # end
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
  #puts "Enter command"
  while line = gets
    case line.chomp
    when "CREATE"
      notes << create_note
      #puts "Note created; what would you like to do next?"
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

  #print_notes(notes)
end

capture
