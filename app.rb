require 'octokit'
require 'sinatra'

enable :sessions

get '/' do
  erb :search
end

post '/form' do
  redirect "/search-code/#{params[:keyword]}/#{params[:language]}/#{params[:account]}"
end

get '/search-code/:words/:language/:user' do
  data = get_data(params[:words],params[:language],params[:user])
  erb :results, :locals => {:total_count => data[:total_count], :results => data[:urls]}
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
  client = Octokit::Client.new :access_token => ENV["MYGHTOKEN"]  
  results = client.search_code("#{word} language:#{language} user:#{user}")
  data[:total_count] = results.total_count
  data[:urls] = Array.new
  results.items.each do |x|
    data[:urls] << {:name => x[:name], :repo_name => x[:repository][:name], :html_url => x[:html_url]}
  end
  return data
end