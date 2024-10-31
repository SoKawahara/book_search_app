class SearchesController < ApplicationController

  require 'json'
  require 'uri'

  def top
  end

  def index
    #フォームに入力された条件、検索件数、内容を取得する
    type = params[:type]
    number = params[:number]
    contents = params[:content]
    #実際にAPIをたたく処理を行う
    url = "https://www.googleapis.com/books/v1/volumes?q="
    if type == "タイトル"
      url += "intitle:#{URI.encode_www_form_component(contents)}"
    elsif type == "著者"
      url += "inauthor:#{URI.encode_www_form_component(contents)}"
    else 
      url += "inpublisher:#{URI.encode_www_form_component(contents)}"
    end
    url += "&maxResults=#{number}&key=#{ENV['API_KEY']}"
    puts "url: #{url}"
    
    result = fetch(url)
    render json: result
  end

  def show
  end

   
  #APIをたたく処理を書く
  def fetch(url)
    response = Faraday.get(url)
    if response.success?
      JSON.parse(response.body)
    else
      "取得できませんでした"
    end  
  end

    
end
