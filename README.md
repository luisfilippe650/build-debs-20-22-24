# Descrição do Script `build.sh`

## Visão Geral

O `build.sh` é um script de automação de build responsável por gerar pacotes `.deb` do projeto **rackctl** para múltiplas versões do Ubuntu de forma isolada e reproduzível, utilizando Docker como ambiente de compilação.

---

## Fluxo de Execução

```
build.sh
   │
   ├── Para cada versão Ubuntu (20.04 / 22.04 / 24.04)
   │       │
   │       ├── 1. docker build   → Cria imagem com ambiente de compilação
   │       ├── 2. docker create  → Instancia container (sem executar)
   │       ├── 3. docker cp      → Copia o .deb gerado para dist/ubuntu-<versão>/
   │       ├── 4. docker rm      → Remove o container
   │       └── 5. docker rmi     → Remove a imagem (limpeza)
   │
   └── Exibe mensagem de conclusão
```

---

## Detalhamento de Cada Etapa

### 1. Definição das versões alvo
```bash
VERSIONS=("20.04" "22.04" "24.04")
```
Array com as versões LTS do Ubuntu para as quais o pacote será compilado. Cada versão gera um artefato independente.

---

### 2. Build da imagem Docker
```bash
docker build \
    --build-arg UBUNTU_VERSION="$VERSION" \
    -t "$IMAGE_NAME" \
    -f Dockerfile.build .
```
Constrói uma imagem Docker passando a versão do Ubuntu como argumento de build (`ARG`). O `Dockerfile.build` usa esse argumento para configurar o ambiente correto (dependências, Python, etc.) e já executa a compilação do `.deb` durante o build da imagem.

> O pacote `.deb` é gerado **dentro da imagem**, não em execução do container.

---

### 3. Criação do container (sem execução)
```bash
CONTAINER_ID=$(docker create "$IMAGE_NAME")
```
Instancia um container a partir da imagem **sem iniciá-lo**. O objetivo é apenas ter acesso ao sistema de arquivos interno para copiar o artefato gerado.

---

### 4. Cópia do artefato
```bash
docker cp "$CONTAINER_ID:/app/deb_dist/." "dist/ubuntu-$VERSION/"
```
Copia o conteúdo do diretório `/app/deb_dist/` (onde o `stdeb` gera o `.deb`) para a pasta local `dist/ubuntu-<versão>/`. O `|| true` garante que uma falha nessa etapa não aborte o script inteiro.

---

### 5. Limpeza
```bash
docker rm "$CONTAINER_ID"
docker rmi "$IMAGE_NAME" || true
```
Remove o container e a imagem Docker após a extração do artefato, liberando espaço em disco. A remoção da imagem é opcional (`|| true`), então falhas são ignoradas.

---

## Saída Gerada

Ao final da execução, os pacotes estarão organizados em:

```
dist/
├── ubuntu-20.04/
│   └── python3-rackctl_<versão>_all.deb
├── ubuntu-22.04/
│   └── python3-rackctl_<versão>_all.deb
└── ubuntu-24.04/
    └── python3-rackctl_<versão>_all.deb
```

---

## Comportamentos Importantes

| Comportamento | Detalhe |
|---|---|
| `set -e` | O script aborta imediatamente se qualquer comando falhar |
| `\|\| true` no `docker cp` | Falha na cópia é ignorada — o loop continua para a próxima versão |
| `\|\| true` no `docker rmi` | Falha ao remover a imagem é ignorada (ex: imagem em uso) |
| Build isolado por versão | Cada versão usa sua própria imagem, sem interferência entre builds |
| Compilação no build da imagem | O `.deb` é gerado no `RUN` do Dockerfile, não em `CMD`/`ENTRYPOINT` |

---

## Dependências Necessárias

- **Docker** — instalado e com daemon em execução
- **Bash** — versão 4.0 ou superior (uso de arrays)
- **`Dockerfile.build`** — deve estar na raiz do projeto
- **`setup.py`** — necessário para o `stdeb` gerar o `.deb`
