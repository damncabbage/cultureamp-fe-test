Culture Amp Frontend Test
=========================


## Setup

Requirements:
* [Node.js 8+](https://nodejs.org/en/download/)
* [Ruby 2.3+](https://www.ruby-lang.org/en/documentation/installation/)
* [Elm 0.18](http://elm-lang.org/install)
* Linux or macOS (this hasn't been tested on Windows)

To get set up, in a `git clone` of this repository, run:

```
mv -i .env.development .env
npm install
bundle install
```

And then either start development with:

```
bundle exec foreman start
```

... or build and start production with:

```
# These ()s are starting a sub-shell so your environment
# isn't polluted with NODE_ENV=production, etc.
(
  set -eux
  set -o allexport
  source .env.production
  npm run build
  bundle exec rackup config.ru -p ${BACKEND_PORT}
)
```


## Notes

Relating to npm:
* `npm audit` shows 7 problems, but they're all either because of (or upstream of) `elm-webpack-loader`.
* `elm-css-modules-loader` expects `webpack < 4`, but it works fine with 4; please ignore the warning.
