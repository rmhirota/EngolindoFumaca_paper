# Engolindo Fuamaca

1. Crie usuário para acessar ao [Atmospheric Data Store (ADS)](https://ads.atmosphere.copernicus.eu/#!/home). 
2. Identifique sua [chave](https://api.ecmwf.int/v1/key/).
3. Instale o [pip install ecmwf-api-client](#pip-install-ecmwf-api-client)
[Acesso aos dados publicos](https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets)

```commandline
mkdir EngolindoFumaca
cd EngolindoFumaca
git init
touch README.md
python -m venv .venv
```
# configurando acesso

1. Criar o arquivo `.cdsapirc` e adicionar os [dados de acesso](https://ads.atmosphere.copernicus.eu/api-how-to) a ele:
2. [Mais infos aqui](https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets)

```commandline
touch ~/.cdsapirc
```

# instalando o cdsapi

```commandline
pip install --upgrade pip
pip install cdsapi 
pip install python-dateutil
```

# Usando cdsapi

```commandline
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'cams-global-atmospheric-composition-forecasts',
    {
        'type': 'forecast',
        'format': 'netcdf_zip',
        'variable': 'particulate_matter_2.5um',
        'date': '2023-05-01/2023-05-02',
        'time': [
            '00:00', '12:00',
        ],
        'leadtime_hour': [
            '0', '12', '6',
        ],
    },
    'download.netcdf_zip')
```