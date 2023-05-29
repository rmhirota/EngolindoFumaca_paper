# Engolindo Fuamaca

Repo para organização dos dados para artigo.

1. [Crie o ambiente de trabalho](#criando-ambiente-de-trabalho)
1. [Configurando acesso](#configurando-acesso)
   1. Crie usuário para acessar ao [Atmospheric Data Store (ADS)](https://ads.atmosphere.copernicus.eu/#!/home). 
   1. Identifique sua [chave](https://api.ecmwf.int/v1/key/).
   1. Instale o [cdsapi](#instalando-o-cdsapi)
1. [Baixe os dados](#usando-cdsapi)
1. [Organize os dados baixados](#organizando-os-dados)

[Acesso aos dados publicos](https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets)

## Criando ambiente de trabalho

```commandline
#mkdir EngolindoFumaca
#cd EngolindoFumaca
#git init
#touch README.md
git clone git@github.com:FelipeSBarros/EngolindoFumaca_paper.git
cd EngolindoFumaca_paper
python -m venv .venv
```

## configurando acesso

1. Criar o arquivo `.cdsapirc` e adicionar os [dados de acesso](https://ads.atmosphere.copernicus.eu/api-how-to) a ele:
2. [Mais infos aqui](https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets)

```commandline
touch ~/.cdsapirc
# colocar infos de chave no arquivo
```

### instalando o cdsapi

```commandline
pip install --upgrade pip
pip install cdsapi 
pip install python-dateutil
```

### Usando cdsapi

Exemplo de requisição usando o `cdsapi`:

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

[**Script python usado**](./Download_pm25_monthly.py)

## Organizando os dados

* unzip;
[Script de organização dos dados](./organinzing_cams_data.py)

## Conversão em objeto R

* Consolidação dos `netCDF` em um `rds` mensal;
* Consolidação dos `netCDF` em um `rds` mensal com valor médio diário de pm<2.5;
* Extração dos valores de pm>2.5 médios diários por município;
 
[Processo desenvolvido em R](./Scripts/R/1_organize_extract_pm25.R)
