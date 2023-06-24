import requests
import json
import time
from prometheus_client import start_http_server, Gauge
url_numero_pessoas = "http://api.open-notify.org/astros.json"

def pega_numero_astronautas():
    try:
        """
        Pegar o número de astronautas que estão no espaço!
        """
        response = requests.get(url_numero_pessoas)
        data = response.json()
        print(data['number'])
        return data['number']
        
    
    except Exception as e:
        print("Tivemos problemas para acessar a URL")
        raise e
def atualiza_metricas():
    try:
        """
        Atualiza as metricas com o número de astronautas no espaço
        """
        numero_pessoas = Gauge('numero_de_astronautas', 'Número de astronautas no espaço')
        while True:
            numero_pessoas.set(pega_numero_astronautas())
            time.sleep(10)
        print("O número de Astronautas no espaço nesse momento é: %s" %pega_numero_astronautas() )
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
        print("Tivemos problemas iniciar o http_server")
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
        print("Tivemos problemas na inicialização do Exporter")
        exit(1)
if __name__ == '__main__':
    main()
    exit(0)






    
