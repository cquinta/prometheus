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
        print(data)
        return data['number']
        
    
    except Exception as e:
        print("Tivemos problemas para acessar a URL")
        raise e
pega_numero_astronautas()