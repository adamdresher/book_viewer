require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

helpers do
  # takes a String
  # return an Array of Strings
  # adds 'id' tag to each String paragraph
  def chunk_paragraphs(text)
    text.split(/\n\n/).map.with_index do |paragraph, idx|
      "<p id=#{idx}>#{paragraph}</p>"
    end
  end

  # takes a String number
  # return a Hash of { title: 'name', num: num, contents: 'txt' }
  def describe_chapter(chp_num)
    { title: @toc[chp_num - 1], num: chp_num, contents: File.read("data/chp#{chp_num}.txt") }
  end

  # takes a String
  # return an Array of Hashes
  # each Hash represents a chapter's components
  def select_chapters(query)
    selected_chapters = []

    @toc.each_with_index do |chp, idx|
      components = describe_chapter(idx + 1)
      if components[:contents].downcase.match? query.downcase
        selected_chapters.push components
      end
    end

    selected_chapters
  end

  # takes a String
  # returns a new String with `<b>..</b>` wrapping all instances of query
  def highlight(paragraph, query)
    highlighted_text = paragraph.gsub query, "<b>#{query}</b>"
  end
end

before do
  @toc = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Advenures of Sherlock Holmes"

  erb :home
end


get "/chapter/:number" do
  @num = params['number'].to_i

  redirect "/" unless (1.. @toc.size).cover? @num

  @chapter_title = @toc[@num - 1]
  @title = "Chapter #{@num}: #{@chapter_title}"
  @chapter_content = chunk_paragraphs File.read("data/chp#{@num}.txt")

  erb :chapter
end

get "/search" do
  @query = params['query']
  @search_results = select_chapters(@query)

  erb :search
end

not_found do
  redirect "/"
end
