require 'rest-client'
require 'csv'

client_id = ''
client_secret = ''
bearer = ''
cidade = ''
filtro = ''

client_id = 'parknet-waffle'
client_secret = 'aIXe5PoKmsFyO6z63j8huaETKtm~'
bearer = 'af48a24d-245c-4851-96e4-54bb0859d81b'
cidade = 'Porto Alegre'
filtro = 'garagem'


token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', {:Authorization => 'Bearer ' + bearer},{:params => {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => 'client_credentials'}}
token = JSON.load(token)

puts token["access_token"]

places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50}}
places = JSON.load(places)

start = 0
total = places["results"]["header"]["found"].to_int

file = CSV.open("./Porto Alegre.csv", "wb")
file << ['Nome', 'Pais', 'Estado', 'Telefone', 'Cidade', 'Bairro', 'Numero', 'CEP']
while start < total do
    places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50, 'start' => start}}
    places = JSON.load(places)
    
    
    start = start + 50
    for place in places["results"]["places"]
        temp = Array.new

        puts "Nome: " + place["name"]
        temp << place["name"]
        puts "Pais: " + place["address"]["country"]
        temp << place["address"]["country"]
        puts "Estado: " + place["address"]["state"]
        temp << place["address"]["state"]
        begin
            for phone in  place["phones"]
                puts "Telefone: " + phone
            end
            temp << place["phones"].join(" - ")
        rescue
            puts "Telefone: "
            temp << ""
        end
        
        puts "Cidade: " + place["address"]["city"]
        temp << place["address"]["city"]
        begin
            puts "Bairro: " + place["address"]["district"]
            temp << place["address"]["district"]
        rescue
            puts "Bairro: "
            temp << ""
        end
        
        puts "Rua: " + place["address"]["street"]
        temp << place["address"]["street"]
        begin
            puts "Numero: " + place["address"]["number"]
            temp << place["address"]["number"]
        rescue
            puts "Numero: "
            temp << ""
        end
        
        begin
            puts "CEP: " + place["address"]["zipcode"]
            temp << place["address"]["zipcode"]
        rescue
            puts "CEP: "
            temp << "" 
        end
        puts ""
        file << temp
    end
end


puts "fim"