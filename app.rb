require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'

domains = ["app.2g0.xyz","app.2g0.work","app.2g0.info",
    "app.gotoour.site","app.go2link.xyz","app.move2.link",
    "app.2g0.online","app.skip2.xyz","app.skip2.cloud",
    "app.リンクタンシュク.jp","app.ultra-go.info","app.theultrago.xyz"]
    
bads = ["mkr","mrked","dlr","data"]

get '/' do
    @domains = domains
    erb :index
end


post '/mkr' do
    if(domains.include?(params[:selectdomain]) and params[:arg].strip != "" and params[:target].strip != "" and params[:pw].strip != "" and !bads.include?(params[:arg].strip) )
        link = Link.find_by(text: params[:arg],domain: params[:selectdomain])
        if( link == nil )
            Link.create(text: params[:arg],domain: params[:selectdomain],password: params[:pw],target: params[:target])
            redirect "/mrked?domain=" + params[:selectdomain] + "&arg=" + params[:arg] + "&pw=" + params[:pw]
        else
            "Already Exited! <a href='/'>Home</a>"
        end
    end
    "Failed to create short url! <a href='/'>Home</a>"
end


get '/mrked' do
    domain = params[:domain]
    arg = params[:arg]
    pw = params[:pw]
    link = Link.find_by(text: arg,domain: domain)
    if( link != nil && link.password == pw)
        "Original: " + link.target + "<br>Short: http://" + domain + "/" + arg + "<br>Delete it? (click to delete!) -> <a href='/dlr?domain=" + domain + "&arg=" + arg + "&pw=" + pw + "'>DELETE_CONFIRM</a>"
    end
end


get '/dlr' do
    domain = params[:domain]
    arg = params[:arg]
    pw = params[:pw]
    link = Link.find_by(text: arg,domain: domain,password: pw)
    if( link != nil )
        link.destroy()
        "Deleted! <a href='/'>Home</a>"
    end
end

get '/data' do
    a = ""
    domains.each do |domain|
        perDomain = Link.where(domain: domain)
        a = a + "<br>" + domain.to_s + " : " + perDomain.count.to_s
    end
    a + "<br><a href='http://app.ultra-go.info'>Home</a>"
end

get '/:any' do
    domain = request.host
    link = Link.find_by(domain: domain,text: params[:any])
    if( link != nil ) 
        redirect link.target
    else
        redirect "http://app.ultra-go.info/"
    end
end