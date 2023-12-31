import requests
import json
import time
from prometheus_client import start_http_server, Gauge
url_numero_pessoas = "http://api.open-notify.org/astros.json"
url_local_ISS = "http://api.open-notify.org/iss-now.json"

def pega_local_ISS():
    try:
        """
        Pegar o local atual da ISS!
        """
        response = requests.get(url_local_ISS)
        data = response.json()
        return data['iss_position']
        
    
    except Exception as e:
        print("Tivemos problemas para acessar a URL para capturar a posição da ISS")
        raise e

def pega_numero_astronautas():
    try:
        """
        Pegar o número de astronautas que estão no espaço!
        """
        response = requests.get(url_numero_pessoas)
        data = response.json()
        return data['number']    
    except Exception as e:
        print("Tivemos problemas para acessar a URL")
        raise e
def atualiza_metricas():
    try:
        """
        Atualiza as metricas com o número de astronautas no espaço e a localização da ISS
        """
        numero_pessoas = Gauge('numero_de_astronautas', 'Número de astronautas no espaço')
        longitude = Gauge('longitude_iss','Longitude atual da ISS')
        latitude = Gauge('latitude_iss','Latitude atual da ISS')

        while True:
            numero_pessoas.set(pega_numero_astronautas())
            longitude.set(pega_local_ISS()['longitude'])
            latitude.set(pega_local_ISS()['latitude'])
            time.sleep(10)
            print("O número de Astronautas no espaço nesse momento é: %s" %pega_numero_astronautas() )
            print("A longitude atual da ISS é : %s" %pega_local_ISS()['longitude'] )
            print("A latitude atual da ISS é : %s" %pega_local_ISS()['latitude'] )
    except Exception as e:
        print("Tivemos problemas em atualizar a métrica!")
        raise e
def inicia_exporter(): 
    try:
        """
        Iniciar o http server
        """
        start_http_server(8899)
        return True
    except Exception as e: 
        print("Tivemos problemas iniciar o http_server ")
        raise e
def main():
    try:
        """
        Função principal
        """
        inicia_exporter()
        print("HTTP Server iniciado")
        atualiza_metricas()
    except Exception as e:
        print('\nExporter Falhou e Foi Finalizado! \n\n======> %s\n' % e)
        exit(1)
if __name__ == '__main__':
    main()
    exit(0)






    
