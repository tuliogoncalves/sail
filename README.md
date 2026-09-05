# Scriptpage Sail

**v3.0.0**

Ambiente de desenvolvimento local baseado em Docker Compose para os projetos
PHP/Laravel e Node.js da Scriptpage, inspirado no Laravel Sail. Este
repositório concentra a infraestrutura (containers, proxy reverso, bancos de
dados) e uma CLI (`sail`) que orquestra tudo isso, além de wrappers que
permitem rodar `php`, `composer`, `artisan`, `node`, `npm` e `npx` de dentro
do container do projeto sem precisar digitar `docker compose exec` toda vez.

## Visão geral

```
sail_runners/
├── bin/
│   ├── sail.sh              # CLI principal: sail on|off|<projeto> <cmd docker compose>
│   └── sail-dispatch.sh     # dispatcher usado pelos symlinks php/composer/artisan/node/npm/npx
├── server/                  # infraestrutura compartilhada: proxy, bancos, redis + template de projeto
│   ├── docker-compose-proxy.yml     # Nginx Proxy Manager (proxy reverso)
│   ├── docker-compose-db.yml        # MariaDB + Redis
│   ├── docker-compose-mariadb.yml   # MariaDB isolado
│   ├── docker-compose-mysql8.yml    # MySQL 8 isolado
│   ├── docker-compose-sqlserver.yml # SQL Server isolado
│   ├── docker-compose-redis.yml     # Redis isolado
│   ├── docker-compose-dev.yml       # template de projeto (php/nginx/nodejs)
│   └── sail_builders/               # arquivos de apoio para criar novos projetos (env, README, conf)
├── efd-reinf/                # projeto Laravel (PHP 7.4 + nginx)
├── sped-efdreinf/             # projeto Laravel (PHP 7.4 + nginx)
├── install.sh                # instala os comandos em ~/.local/bin
└── uninstall.sh               # remove os comandos instalados
```

Cada projeto roda em containers próprios (`php`, `nginx`, `nodejs`, etc.) e
todos se conectam a uma rede Docker externa chamada `proxy`, compartilhada
com o Nginx Proxy Manager e com os bancos de dados (`mariadb`, `redis`,
`mysql`, `sqlserver`) definidos em `server/`.

## Pré-requisitos

- Docker Engine + Docker Compose plugin instalados
- `~/.local/bin` no `PATH` (o `install.sh` avisa se não estiver)
- `sudo` configurado para o seu usuário (usado por `sail on`/`sail off` para
  ligar/desligar o serviço `docker`)

## Instalação

```bash
git clone <este-repositório> ~/projects/sail_runners
cd ~/projects/sail_runners
./install.sh
```

O script cria, em `~/.local/bin`, symlinks para:

- `sail` → `bin/sail.sh`
- `php`, `composer`, `artisan`/`art`, `node`, `npm`, `npx` → `bin/sail-dispatch.sh`

Se algum desses nomes já existir em `~/.local/bin` (ex.: um `php` ou `node`
instalado localmente), o instalador **pula** o arquivo por padrão e avisa.
Para sobrescrever:

```bash
./install.sh --force
```

Se `~/.local/bin` não estiver no seu `PATH`, adicione ao `~/.bashrc` ou
`~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Para remover tudo que foi instalado (sem tocar em symlinks que não apontam
para este repositório):

```bash
./uninstall.sh
```

## Uso

### Ligar/desligar o Docker

```bash
sail on   # sudo systemctl start docker.socket docker
sail off  # sudo systemctl stop docker.socket docker
```

### Subir a infraestrutura compartilhada

A rede externa `proxy` e os serviços de apoio (proxy reverso, bancos, redis)
ficam em `server/`. Suba o que for necessário antes dos projetos:

```bash
sail server proxy up -d      # Nginx Proxy Manager (admin em http://127.0.0.1:81)
sail server db up -d         # MariaDB + Redis
# alternativas isoladas:
sail server mariadb up -d
sail server mysql8 up -d
sail server sqlserver up -d
sail server redis up -d
```

> A primeira vez que o admin do Nginx Proxy Manager é acessado
> (`http://127.0.0.1:81`), use o usuário padrão `admin@example.com` /
> `changeme` e troque a senha imediatamente.

### Subir um projeto

`sail <projeto> [<nome_curto>] <comandos docker compose>` procura, dentro da
pasta do projeto, um arquivo `docker-compose-<nome_curto>.yml`; se
`<nome_curto>` for omitido (ou o arquivo não existir), usa
`docker-compose.yml`.

```bash
sail efd-reinf up -d          # usa efd-reinf/docker-compose.yml
sail sped-efdreinf up -d      # usa sped-efdreinf/docker-compose.yml
sail server mariadb up -d     # usa server/docker-compose-mariadb.yml
```

Outros comandos docker compose funcionam da mesma forma:

```bash
sail efd-reinf logs -f
sail efd-reinf down
sail efd-reinf ps
```

### Rodar comandos dentro do container do projeto

Dentro da pasta de um projeto que tenha um arquivo `.sail.env` (ver
`server/.sail.env` como exemplo — define `PROJECT_NAME` e `FILE_COMPOSE`), os
comandos abaixo são redirecionados automaticamente para o serviço correto do
container:

```bash
composer install
php artisan migrate
art db:seed          # atalho para "php artisan"
npm install
npx vite build
```

O `sail-dispatch.sh` sobe a árvore de diretórios a partir do `$PWD` até achar
o `.sail.env`, descobre o `docker compose` correto (`FILE_COMPOSE`) e executa
o comando no serviço `php` ou `nodejs`, conforme o comando chamado. Se o
serviço não existir no compose do projeto, ou não estiver rodando, o wrapper
avisa e informa como subir os containers.

### Criando um novo projeto Laravel

O diretório `server/sail_builders` traz um passo a passo (`README`) e os
arquivos de apoio (`env/laravel.env`, `env/.sail.env`, `production.cnf`) para
iniciar um novo projeto usando `docker-compose-dev.yml` como template:

```bash
sail create-back v10.1.1 nome-do-projeto
cd nome-do-projeto
cp server/sail_builders/env/laravel.env .env
cp server/sail_builders/env/.sail.env .sail.env   # ajuste PROJECT_NAME e FILE_COMPOSE
sail build
sail up -d
sail composer install
sail npm install
sail art key:generate
sail art migrate
sail art db:seed
```

## Projetos incluídos

| Projeto         | Stack                          | Compose                     |
|-----------------|---------------------------------|------------------------------|
| `efd-reinf`      | PHP 7.4 + Nginx (porta 8000)     | `docker-compose.yml`          |
| `sped-efdreinf`  | PHP 7.4 + Nginx                 | `docker-compose.yml`          |
| `server`         | Proxy, MariaDB, MySQL 8, SQL Server, Redis, template de projeto | `docker-compose-*.yml` |

## Licença

Uso interno.
