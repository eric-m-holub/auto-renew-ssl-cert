# Auto Renew SSL Cert

## Description

Useful in cases where you have a public DNS record in Hostinger pointing to a local IP and you want to use certbot to add or renew an SSL cert for that record.

## Setup

The 'renewcert.sh' script requires 'expect' as a dependency:
```
sudo apt update
sudo apt install expect
```


## Usage

Replace 'yourdomain.com' with the FQDN you are trying to renew. 

Generate a [Hostinger API key](https://docs.hostinger.com/api-reference/overview) and place it in the same directory as the two bash scripts in a file called '.key'

Run 'renewcert.sh'
