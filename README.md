# Sortal

A basic portal for submitting issues/tickets.

Uses Ruby on Rails.

## Development

1. Install Docker
2. `cp .docker-compose-env.sample .docker-compose-env` # Edit
3. `docker-compose build`
4. `docker-compose run web bundle install` # Updates Gemfile.lock
5. `docker-compose up`
6. Visit [127.0.0.1:3000](http://127.0.0.1:3000)
