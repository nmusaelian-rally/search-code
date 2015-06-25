require 'octokit'
require 'sinatra'
get '/' do
  "search code in github repos"
end
get '/search-code/:words/:user' do
  data = get_data(params[:words],params[:user])
  "found #{data.inspect}"
end

def get_data(word, user)
  data = Hash.new
  client = Octokit::Client.new :access_token => `echo $MYGHTOKEN` 
  results = client.search_code("#{word} language:js user:#{user}")
  data[:total_count] = results.total_count
  data[:html_urls] = Array.new
  results.items.each do |x|
    data[:html_urls] << x[:html_url]
  end
  return data
end