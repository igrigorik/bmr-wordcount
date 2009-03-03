# Ilya Grigorik - February 28 / '09
#
# HTTP driver for a browser based Map-Reduce
#
#  1) Server redirects the client to available jobs
#  2) Client executes javascript map/reduce jobs via JavaScript
#  3) Client emits (POST) intermediate results back to job server
#  4) Client is redirected to next available job (map or reduce)
#  

require "rubygems"
require "sinatra"

configure do
  set :map_jobs, Dir.glob("data/*.txt")
  set :reduce_jobs, []
  set :result, nil
end

get "/" do
  redirect "/map/#{options.map_jobs.pop}" unless options.map_jobs.empty?
  redirect "/reduce"                      unless options.reduce_jobs.empty?
  redirect "/done"
end

get "/map/*"  do erb :map,    :file => params[:splat].first; end
get "/reduce" do erb :reduce, :data => options.reduce_jobs;  end
get "/done"   do erb :done,   :answer => options.result;     end

post "/emit/:phase" do
  case params[:phase]
  when "reduce" then
    options.reduce_jobs.push params['count']
    redirect "/"

  when "finalize" then
    options.result = params['sum']
    redirect "/done"
  end
end
