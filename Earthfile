FROM elixir:1.9.0-alpine
RUN apk add --no-cache build-base npm git python
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=test

build:
	COPY mix.exs mix.lock ./
	COPY config config
	RUN mix do deps.get, deps.compile
	SAVE ARTIFACT deps /deps AS LOCAL build/deps

test:
	COPY . .
	COPY +build/deps deps
	RUN mix ecto.setup
	RUN mix.test

