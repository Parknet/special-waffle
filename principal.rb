require 'rest-client'

client_id = 'parknet-waffle'
client_secret = 'aIXe5PoKmsFyO6z63j8huaETKtm~'
bearer = 'af48a24d-245c-4851-96e4-54bb0859d81b'
cidade = 'Sao Paulo'
filtro = 'garagem'

token = RestClient.post 'https://api.apontador.com.br/v2/oauth/token', {:Authorization => 'Bearer ' + bearer},{:params => {'client_id' => client_id, 'client_secret' => client_secret, 'grant_type' => 'client_credentials'}}
token = JSON.load(token)

puts token["access_token"]

places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50}}
places = JSON.load(places)

start = 0
total = places["results"]["header"]["found"].to_int

list = []
while start < total do
    places = RestClient.get 'https://api.apontador.com.br/v2/places/',  {:Authorization => 'Bearer ' + token["access_token"], :params => {'q'=> filtro, 'wt' => 'json', 'fq' => 'address.city:"'+ cidade +'"', 'rows' => 50, 'start' => start}}
    places = JSON.load(places)

    start = start + 50
    for place in places["results"]["places"]
        puts "Nome: " + place["name"]
        puts "Pais: " + place ["address"]["country"]
        puts "Estado: " + place ["address"]["state"]
        begin
            for phone in  place["phones"]
                puts "Telefone: " + phone
            end
        rescue
            puts "Telefone: "
        end
        
        puts "Cidade: " + place ["address"]["city"]
    
        begin
            puts "Bairro: " + place ["address"]["district"]
        rescue
            puts "Bairro: "
        end
        
        puts "Rua: " + place ["address"]["street"]
        begin
            puts "Numero: " + place ["address"]["number"]
        rescue
            puts "Numero: "
        end
        
        begin
            puts "CEP: " + place ["address"]["zipcode"]
        rescue
            puts "CEP: "
        end
        puts " "
    end
end


puts "fim"