require 'rest-client'
require 'json'
require 'csv'

config = JSON.load(File.read("./config.json"))
client_id = config['client_id']
client_secret = config['client_secret']
cidade = 'Pelotas'
filtro = 'Estacionamento'


#token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', {:Authorization => 'Bearer ' + bearer},{:params => {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => 'client_credentials'}}
token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', :client_id => client_id, :client_secret => client_secret, :grant_type => 'client_credentials'
token = JSON.load(token)

puts token["access_token"]

places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50}}
places = JSON.load(places)

start = 0
total = places["results"]["header"]["found"].to_int

file = CSV.open("./Porto Alegre.csv", "wb")
file << ['Nome', 'País', 'Estado', 'Telefone', 'Cidade', 'Bairro', 'Número', 'CEP']
while start < total do
    places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50, 'start' => start}}
    places = JSON.load(places)
    
    
    start = start + 50
    for place in places["results"]["places"]
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
        file << temp
    end
end

puts total.to_s + " resultados."
puts "fim"