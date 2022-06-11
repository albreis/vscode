# ***Ambiente de Desenvolvimento Fullstack***

Um container Docker com várias ferramentas geralmente utilizadas por um dev fullstack em seu dia a dia.

## Linguagens e Ferramentas

* Ruby
* Python
* PHP8
* PHP7.4
* NodeJS
* Android SDK

## Algumas ferramentas CLI

**opencode** - CLI para trabalhar com temas Tray Commerce

**doctl** - CLI da Digital Ocean

**kubectl** - CLI do Kubernetes

**aws** - CLI da AWS

**gcloud**  - CLI do Google Cloud

**shopify** - CLI do Shopify

**git** - CLI do Git

**wp** - CLI do WordPress

## Variáveis de Ambiente

**TZ** - Timezone

**PASSWORD** - Senha utilizada para login no navegador

**SUDO_PASSWORD** - Senha usada para comandos sudo no terminal

**DEFAULT_WORKSPACE** - Área de tralhado padrão

## Docker compose

```yaml
code-server:
      image: albreis/vscode:latest
      environment:
        - TZ=Americaca/Sao_Paulo
        - PASSWORD=1234
        - SUDO_PASSWORD=1234
        - DEFAULT_WORKSPACE=/home/public_html   
      volumes:
        # Diretório contendo os arquivos que você quer acessar
        - /home/usuario/public_html:/home/public_html:rw
        # Monte o /config do container para criar persistencia dos dados
        # Por exemplo configurações do VS Code, extensões instaladas, etc. 
        # Sem a persistência ele será resetado toda vez que iniciar o container
        - /home/usuario/config:/config:rw
```

## Docker run

```bash
docker run -p 8080:8443 \
   -v /home/usuario/config:/config:rw \
   -v /home/usuario/public_html:/home/public_html:rw \
   -e TZ=Americaca/Sao_Paulo \
   -e PASSWORD=1234 \
   -e SUDO_PASSWORD=1234 \
   -e DEFAULT_WORKSPACE=/home/public_html \
   albreis/vscode:latest
```

## Suporte

ER Soluções Web LTDA

https://ersolucoesweb.com.br