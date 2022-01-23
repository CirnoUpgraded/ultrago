require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'

domains = ["app.2g0.xyz","app.2g0.work","app.2g0.info",
    "app.gotoour.site","app.go2link.xyz","app.move2.link",
    "app.2g0.online","app.skip2.xyz","app.skip2.cloud",
    "app.リンクタンシュク.jp","app.ultra-go.info","app.theultrago.xyz","you.brusy.xyz",
    "you.brusy.work","app.brusy.xyz","app.brusy.work","app.move2link.co","app.move2.cc","app.let-move.me","app.theultrago.me"]
    
bads = ["mkr","mrked","dlr","data","fusianasan"]
langs = ["jp"]

get '/' do
    @domains = domains
    if(request.host == "app.xn--pckax5a0p0a7dc.jp" and params[:lang] == nil)
        redirect "?lang=jp"
    end
    if(params[:lang] != nil and langs.include?(params[:lang]))
        lang = params[:lang].strip
        if(lang == "jp")
            erb :index_JP
        end
    elsif(params[:lang] != nil and !langs.include?(params[:lang]))
        redirect '/'
    else
        erb :index
    end
end


post '/mkr' do
    if(domains.include?(params[:selectdomain]) and params[:arg].strip != "" and params[:target].strip != "" and params[:pw].strip != "" and !bads.include?(params[:arg].strip) )
        link = Link.find_by(text: params[:arg],domain: params[:selectdomain])
        if( params[:selectdomain].strip == "app.リンクタンシュク.jp" )
            link = Link.find_by(text: params[:arg],domain: "app.xn--pckax5a0p0a7dc.jp")
        end
        if( link == nil )
            if(params[:selectdomain].strip == "app.リンクタンシュク.jp")
                Link.create(text: params[:arg],domain: "app.xn--pckax5a0p0a7dc.jp",password: params[:pw],target: params[:target])
                redirect "/mrked?domain=app.xn--pckax5a0p0a7dc.jp&arg=" + params[:arg] + "&pw=" + params[:pw]
            else
                Link.create(text: params[:arg],domain: params[:selectdomain],password: params[:pw],target: params[:target])
            end
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
        if(domain.strip == "app.xn--pckax5a0p0a7dc.jp")
            domain = "app.リンクタンシュク.jp"
        end
        "Original: " + link.target + "<br>Short: http://" + domain + "/" + arg + "<br>Delete it? (click to delete!) -> <a href='/dlr?domain=" + params[:domain] + "&arg=" + arg + "&pw=" + pw + "'>DELETE_CONFIRM</a>"
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
    am = 0
    domains.each do |domain|
        if(!(domain.strip == "app.xn--pckax5a0p0a7dc.jp"))
            if(domain.strip == "app.リンクタンシュク.jp")
                domain = "app.xn--pckax5a0p0a7dc.jp"
            end
            perDomain = Link.where(domain: domain)
            if(domain.strip == "app.xn--pckax5a0p0a7dc.jp")
                a = a + "<br>app.リンクタンシュク.jp : " + perDomain.count.to_s
            else
                a = a + "<br>" + domain.to_s + " : " + perDomain.count.to_s
            end
            am = am + perDomain.count
        end
    end
    am = Link.count - am
    a + "<br>Deleted: " + am.to_s + "<br><a href='http://app.ultra-go.info'>Home</a>"
end

get '/fusianasan' do
    domain = params[:domian]
    arg = params[:arg]
    target = Link.find_by(text: arg,domain: domain)
    if( target != nil )
        shows = ""
        @threadList = Ip.where(domain: domain,arg: arg).order(id: "DESC")
        @threadList.each do |i|
            shows += ( i.created_at.to_s + " | " + i.ip ) + "<br>"
        end
        shows + "<title>FUSIANASAN | " + domain + "/" + arg + "</title>"
    else
        redirect "https://www.google.com/search?q=fusianasan"
    end
end


get '/:any' do
    domain = request.host
    link = Link.find_by(domain: domain,text: params[:any])
    if( link != nil )
        Ip.create(ip: request.ip.to_s,domain: link.domain,arg: params[:any])
        redirect link.target
    else
        redirect "http://app.ultra-go.info/"
    end
end