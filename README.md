# rackctl — Debian Package Builder

> Ferramenta de linha de comando para gerenciamento de racks, com suporte a empacotamento `.deb` nativo para múltiplas versões do Ubuntu.

---

## Descrição

O **rackctl** é uma ferramenta CLI desenvolvida em Python para gerenciamento e controle de racks de servidores. Este repositório contém toda a infraestrutura necessária para compilar e distribuir pacotes `.deb` compatíveis com as versões LTS do Ubuntu (20.04, 22.04 e 24.04), utilizando Docker para garantir builds isolados e reproduzíveis em cada ambiente alvo.

---

## Pré-requisitos

- [Docker](https://www.docker.com/) instalado e em execução
- Bash (Linux/macOS ou WSL no Windows)
- Acesso à internet para download das imagens base do Ubuntu

---

## Estrutura do Projeto

```
.
├── Dockerfile.build        # Dockerfile multi-versão para build do .deb
├── build.sh                # Script principal de build para todas as versões
├── setup.py                # Configuração do pacote Python (usado pelo stdeb)
├── dist/
│   ├── ubuntu-20.04/       # Pacote .deb gerado para Ubuntu 20.04
│   ├── ubuntu-22.04/       # Pacote .deb gerado para Ubuntu 22.04
│   └── ubuntu-24.04/       # Pacote .deb gerado para Ubuntu 24.04
└── ...
```

---

## Como Buildar

Execute o script de build para gerar os pacotes `.deb` para todas as versões suportadas do Ubuntu:

```bash
chmod +x build.sh
./build.sh
```

O script irá:

1. Iterar sobre as versões `20.04`, `22.04` e `24.04`
2. Construir uma imagem Docker isolada para cada versão
3. Compilar o pacote `.deb` dentro do container
4. Exportar o artefato para `dist/ubuntu-<versão>/`
5. Remover o container e a imagem após o build

Os pacotes finais estarão disponíveis em:

```
dist/
├── ubuntu-20.04/
├── ubuntu-22.04/
└── ubuntu-24.04/
```

---

## Instalação do Pacote

Após o build, instale o pacote na máquina de destino:

```bash
sudo dpkg -i dist/ubuntu-22.04/python3-rackctl_*.deb
sudo apt-get install -f  # Resolve dependências, se necessário
```

---

## Versões Suportadas

| Ubuntu | Status |
|--------|--------|
| 20.04 LTS (Focal) | ✅ Suportado |
| 22.04 LTS (Jammy) | ✅ Suportado |
| 24.04 LTS (Noble) | ✅ Suportado |

---

## Dependências Python

O pacote inclui as seguintes dependências:

- `PyYAML` — Parsing de arquivos de configuração YAML
- `requests` — Comunicação HTTP com APIs
- `python-dotenv` — Gerenciamento de variáveis de ambiente via `.env`

---

## Como Funciona o Build

O `Dockerfile.build` utiliza um argumento `UBUNTU_VERSION` para adaptar o ambiente de compilação conforme a versão do sistema operacional alvo. O empacotamento é feito com o [`stdeb`](https://github.com/astraw/stdeb), que converte pacotes Python (`setup.py`) em pacotes `.deb` nativos.

```bash
# Build manual para uma versão específica
docker build --build-arg UBUNTU_VERSION=22.04 -t rackctl-builder-ubuntu-22.04 -f Dockerfile.build .
```

---

## Desenvolvimento

Para contribuir ou modificar o projeto:

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/rackctl.git
cd rackctl

# Instale as dependências localmente
pip install -e ".[dev]"
```

---

## Licença

Distribuído sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.
