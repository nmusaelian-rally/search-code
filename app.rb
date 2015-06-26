require 'octokit'
require 'sinatra'

enable :sessions

get '/' do
  "search code in github repos"
end
get '/search-code/:words/:language/:user' do
  data = get_data(params[:words],params[:language],params[:user])
  erb :results, :locals => {:total_count => data[:total_count], :results => data[:html_urls]}
end
not_found do
  session[:message] = request.fullpath
  redirect "/not-found"
end

get '/not-found' do
  wrong_path = session[:message]
  expected_syntax = "/search-code/keyword/language/account"
  message = "Page not found. The URL should follow this format:"
  erb :notfound, :locals => {:wrong_path => wrong_path, :message => message, :expected_syntax => expected_syntax}
end


def get_data(word,language,user)
  data = Hash.new
  client = Octokit::Client.new :access_token => `echo $MYGHTOKEN` 
  results = client.search_code("#{word} language:#{language} user:#{user}")
  data[:total_count] = results.total_count
  data[:html_urls] = Array.new
  results.items.each do |x|
    data[:html_urls] << x[:html_url]
  end
  return data
end