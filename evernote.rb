#require 'pry'
require 'time'

class Note
  attr_accessor :guid, :tags, :content, :deleted
  attr_reader :created
  @@notes = []

  def initialize()
    @@notes << self
    @tags = []
    @content = ""
    @deleted = false
  end

  def has_content?(content)
    @content.downcase.split(/\W+/).include?(content)
  end

  def has_prefix?(prefix)
    exists = @content.downcase.split(/\W+/).detect do |word|
      word.start_with?(prefix)
    end
    !!exists
  end

  def created=(date_string)
    @created = Time.strptime(date_string,'%Y-%m-%dT%H:%M:%SZ')
  end

  def self.find_note(guid)
  @@notes.detect {|note| note.guid == guid}
  end

  def self.all
    @@notes.select {|note| !note.deleted}
  end

end

def parse_line(line)
  content = line.scan(/>.*</).first
  content = content ? content[1..-2] : ""
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
    when "<guid>"
      note.guid = input[:content]
    when "<created>"
      note.created = input[:content]
    when "<tag>"
      note.tags << input[:content]
    when "<content>"
      while (line = gets.strip) != "</content>"
        note.content << line + "\n"
      end
    end 
  end
  return note
end

def delete_note
  guid = gets.chomp
  note_to_delete = Note.find_note(guid)
  if note_to_delete
    note_to_delete.deleted = true
  end
end

def update_note
  while (line = gets.chomp) != "</note>"
    input = parse_line(line)
    case input[:tag]
    when "<note>"
    when "<guid>"
      guid = input[:content]
      note = Note.find_note(guid)
      note.tags = []
      note.content = ""
    when "<created>"
      note.created = input[:content]
    when "<tag>"
      note.tags << input[:content]
    when "<content>"
      while (line = gets.strip) != "</content>"
        note.content << line + "\n"
      end
    end 
  end
  return note
end

def search_notes
  results = []
  possibles = []
  gets.chomp.split(" ").each do |search_term|
    if search_term.start_with?("tag:")
      if search_term.end_with?("*")
        possibles = tag_prefix_search(search_term.sub("tag:","")[0..-2])
      else
        possibles = tag_exact_search(search_term.sub("tag:",""))
      end
    elsif search_term.start_with?("created:")
      possibles = created_date_search(search_term.sub("created:",""))
    elsif search_term.end_with?("*")
      possibles = prefix_search(search_term[0..-2])
    else
      possibles = exact_search(search_term)
    end

    if results == []
      results = possibles
    else
      results = results & possibles
    end
  end

  puts format_results(results.flatten)
end

#make these class methods, make notes a class variable
def tag_prefix_search(search_term)
  Note.all.select do |note|
    note.tags.detect do |tag|
      tag.start_with?(search_term)
    end
  end
end

def tag_exact_search(search_term)
  Note.all.select {|note| note.tags.include?(search_term)}
end

def created_date_search(search_term)
  search_date = Time.strptime(search_term,'%Y%m%d')
  Note.all.select {|note| note.created > search_date}
end

def prefix_search(search_term)
  Note.all.select {|note| note.has_prefix?(search_term)}
end

def exact_search(search_term)
  Note.all.select {|note| note.has_content?(search_term)}
end

def format_results(matches)
  matches.sort_by{|note| note.created}.collect {|match| match.guid}.join(",")
end

def capture
  notes = []
  while line = gets
    case line.chomp
    when "CREATE"
      create_note
    when "DELETE"
      delete_note
    when "UPDATE"
      update_note
    when "SEARCH"
      search_notes
    else
      break
    end
  end
end

capture
