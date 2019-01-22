# Kasa Ruby

A Ruby wrapper for the TP-Link Kasa API

Base API URL: https://wap.tplinkcloud.com
Regional URLs:
- US: https://use1-wap.tplinkcloud.com
- APAC: https://aps1-wap.tplinkcloud.com
- Europe: https://eu-wap.tplinkcloud.com

This is a simple Ruby wrapper that makes it easy to interact with the TP-Link Kasa Smart Home API. As long as you have generated an API Token and have a list of device IDs to interact with the usage is simple.

Create two .env files after pulling the repo: config.env & devices.env

- Place your API token and API URL in config.env
```
API_TOKEN='<token>'
API_URL='<url>'
```
- Place your device name => ID in devices.env
```
DEVICE_NAME='<id>'
```

Visit https://cynicalengineering.com to learn how to interact with the API, generate a token and use this wrapper.
