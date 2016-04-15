require 'csv'

def crawler(start, token, client_id, client_secret, cidade, filtro, list, mutex)
    places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => ('address.city:"' + cidade + '"'), 'rows' => 50, 'start' => start}}
    places = JSON.load(places)

    
    begin
        puts places["results"]["places"].size().to_s()
    rescue
        return
    end
    start = start + 50
    for place in places["results"]["places"] do
        temp = Array.new

        temp << place["name"]
        temp << place["address"]["country"]
        temp << place["address"]["state"]
        begin
            temp << place["phones"].join(" - ")
        rescue
            temp << nil
        end
        
        temp << place["address"]["city"]
        begin
            temp << place["address"]["district"]
        rescue
            temp << nil
        end
        
        temp << place["address"]["street"]
        begin
            temp << place["address"]["number"]
        rescue
            temp << nil
        end
        
        begin
            temp << place["address"]["zipcode"]
        rescue
            temp << nil 
        end

        list << temp
    end
end

class ApontadorController < ApplicationController
    def index
    end
    def csv
        mutex = Mutex.new
        client_id = "parknet-waffle"
        client_secret = ""
        cidade = params[:cidade]
        filtro = params[:busca]
        
        lista = []
        
        #token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', {:Authorization => 'Bearer ' + bearer},{:params => {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => 'client_credentials'}}
        token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', :client_id => client_id, :client_secret => client_secret, :grant_type => 'client_credentials'
        token = JSON.load(token)
        
        puts token["access_token"]
        
        places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 10}}
        places = JSON.load(places)
        
        start = 0
        total = places["results"]["header"]["found"].to_int
        
        while start <= total do
            crawler(start, token, client_id, client_secret, cidade, filtro, lista, mutex)
            start = start + 50
        end
        

        file = CSV.generate do |csv| 
            csv << ['Nome', 'País', 'Estado', 'Telefone', 'Cidade', 'Bairro', 'Número', 'CEP']
            for linha in lista do
                csv << linha
            end
        end
        puts total.to_s+" resultados"
        send_data file, :type => "text/plain", 
            :filename=>"cidade.csv",
            :disposition => 'attachment'
    end
end
