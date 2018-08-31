Culture Amp Frontend Test
=========================


Setup
-------------------------

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

And then start the development server with:

```
bundle exec foreman start
```

... or run the test suites with:

```
npm run test
bundle exec rake
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


### Flake-Out Mode

There's another mode (works in both development and production) that has the API sometimes be slow, or raise HTTP 500s; you can start it with:

```
env FLAKEOUT=1 bundle exec foreman start
```


Notes
-------------------------

### Assumptions

* Surveys have an ID, and the current response doesn't expose them very well. I made this assumption because otherwise the only way to address a survey is via using its URL (from the index) in its entirety as an ID key, which locks together the URL structure of the front- and back-end. I am... not chuffed about this possibility, and adding an ID would be one of my first recommendations if I were working on a team exposing this API.
* Surveys have at least one Theme, and Themes have at least one Question; I have encoded this assumption with the `List.Nonempty` type.
* Survey Questions have an ID, but they're unfortunately represented in a way that you can't rely on them being present (they're in each of the responses, which... maybe be empty? I'm not sure of the assumption here), so I invented surrogate local IDs for UI interactions.


### Problems and Misc Wrinkles

* Relating to npm:
  * `npm audit` shows 7 problems, but they're all either because of (or upstream of) `elm-webpack-loader`.
  * `elm-css-modules-loader` expects `webpack < 4`, but it works fine with 4; please ignore the warning.

* Program structure:
  * `Api.Json` is kind of a mess, but there's enough crossover between both Survey types and generic decoders that it's fine... ish... for the moment.

* Tests
  * The tests are of the "round-trip a data structure through encoder+decoder functions" variety, eg. the routing and JSON tests; admittedly these round-trip fuzzers *are* useful in flushing out silly mistakes, though.
  * The JSON decoder tests are incomplete; they only test the "index" JSON, as an example of what round-trip fuzzers look like.
  * There are no UI functionality tests, which can go pear-shaped even if your types line up; I had a "compiling but not working" UI when hooking up the API-loading functions the first time around.

* Documentation
  * There is way less documentation in this that I'd like. I've tried to make the types as self-documenting as I can manage (eg. encoding assumptions, having transforms like `SurveyFromApi -> SurveyForUI`), but I haven't at all had the time to give this the comments (outside these notes) that I'd like.
