# Rails baseline

The rails-baseline is a web application having some default features such as Sign-in with OTP, Oauth2 with Gmail, Facebook, and Telegram.

## Development Setup
### System dependencies

The following services are required:
- PostgreSQL: 12.4
- Docker
- Docker Compose

### Configuration
Clone the file ```app.env.example``` to ```app.env``` and update

#### To enable feature Sign in with Google:
The Client ID was obtained from the [Google Console](https://developers.google.com/maps/documentation/maps-static/get-api-key). Replace with your own Client ID and Client Secret

```
GOOGLE_CLIENT_ID=client_id
GOOGLE_CLIENT_SECRET=client_secret
```

#### To enable feature Sign in with Telegram:
Further reading: https://core.telegram.org/widgets/login
1) Create a bot: https://core.telegram.org/bots#3-how-do-i-create-a-bot

2) Once you have chosen a bot, send the /setdomain command to @Botfather to link your website's domain to the bot.
 - Steps:
  1. Insert command ```/setdomain```
   2. Select ```your bot```
   3. Insert your ```domain```. example: https://example.com

3) Then configure your bot information with below variables
```
TELEGRAM_BOT_NAME=change_me
TELEGRAM_BOT_SECRET=change_me
TELEGRAM_CALLBACK_URL=https://domain/auth/telegram/callback
```
*Note: Replace domain (if localhost, please use NGROK to get a random domain)*

#### To enable the feature Sentry logger:
Signup with [sentry.io](https://sentry.io) to get SENTRY_DSN and replace the URL
```
SENTRY_DSN=url
```

## Installation
- Install [Docker](https://docs.docker.com/get-docker/)
- install [Docker Compose](https://docs.docker.com/compose/install/)

## Docker development
```docker-compose.yml``` file builds a development environment mounting the current folder and running rails in a development environment.

Run the following commands to have a stable development environment.
```
$ docker-compose run --rm web bundle install
$ docker-compose run --rm web bundle exec rake db:dev
$ docker-compose up
```
And visit [localhost:3000](http://localhost:3000)

### To set up and run the test, run
```
$ docker-compose run --rm web bundle exec rspec spec
```

### To run lint
```
$ docker-compose run --rm web bundle exec rubocop .
```
