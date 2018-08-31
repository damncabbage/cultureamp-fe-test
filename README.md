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

### Design Overview

The API is implemented in Ruby, using Sinatra. It matches the route structure from the example data files (`/`, and `/survey_results/<id>(.json?)`), and serves the files from disk. Everything else is proxied to either static assets and the `index.html` file, or to the Webpack dev server, depending if it's run in dev or production mode.

The UI is a written with Elm, using Webpack to compile it along with other assets, and either serving them all up via the aforementioned dev server, or by producing assets in `dist/` to be served up by Sinatra.

The UI presents two pages: an Index list of surveys, and a Survey page that lists the Themes and Questions for each, along with a summary of survey results. Bar graph summaries are presented for each question to allow for a quick overview of the results.

Elm programs can be put together in a few ways, such has having deeply nested Model and Msg structures, or having everything share the one data type (regardless of "level" of nesting). As an experiment, for the implementation of *this* Elm program I choose to have a mix of both, with:

* The program state `Model` being a nested structure; a top-level record nests the data structures for each specific "component" (the `Page.Index` and `Page.Survey` modules), with each component's `view` and `update` only being concerned with that component's Model definition.  
  Any other dependent data for a component (eg. the base URL for the API) is passed in as function parameters from its parent, encoding the assumption that the responsibility for *changing* that data also rests entirely in the hands of the parent component.

* The program has a `RootMsg` that every component-level `view` and `update` returns as part of its `Cmd RootMsg` return type. Each component has its own `Msg` that the `update` function matches on.  
  To provide a way to get from a component's dedicated `Msg` to the `RootMsg` (however deeply nested it is), a parameter called `lift` (of type `Msg -> RootMsg`) is passed in. The allows the definition of a relatively independent component, with the freedom to move it up and down a tree of components, with the ability to access the top-level Msgs like `ChangeLocation` without needing to provide a dedicated version for each module.

Pages independently fetch (and cache) the JSON data from the server, storing the list of Summaries in the `Index` page's case, and a Map of SurveyIDs to Surveys in the `Summary` page's case. We could additionally localStorage cache (for offline use) this if the results aren't ever going to change.

The UI is also implemented with CSS Modules (using Culture Amp's Webpack plugin) because I've personally wanted to try it out. 😅 The styles are laid out in each Page, with `Page.Common` having things like colour-palette variables and global styles. There is no design or typography system; it's more seat-of-the-pants than what you'd want in a real app, but I also haven't designed a design system from scratch so pants-seating is what's here.


### Implementation Assumptions

Some notes of what I've made assumptions about when implementing this app:

* The response rating in Survey #2 that has a "0" (instead of a "", or "1" through to "5" inclusive) is a typo in the data.
  * There are two ways I could have treated this, assuming it's problem in the data coming from the server (eg. mismatch in assumptions or validation): ignoring the fault (and potentially hiding other faults that fall outside the expected spec), or exploding with an error (thereby depriving a demonstration of a larger and more complicated data set).
  * The latter doesn't seem conducive to a good test, so I opted to silently drop the "0" response (and log it, though admittedly not in a way that's easily caught by a Rollbar-esque service).

* Surveys have an ID, and the current response doesn't expose them very well. I made this assumption because otherwise the only way to address a survey is via using its URL (from the index) in its entirety as an ID key, which locks together the URL structure of the front- and back-end. I am... not chuffed about this possibility, and adding an ID would be one of my first recommendations if I were working on a team exposing this API.

* Surveys have at least one Theme, and Themes have at least one Question; I have encoded this assumption with the `List.Nonempty` type.

* Survey Questions have an ID, but they're unfortunately represented in a way that you can't rely on them being present (they're in each of the responses, which... maybe be empty? I'm not sure of the assumption here), so I invented surrogate local IDs for UI interactions.


### Problems and Wrinkles

Some rougher notes on design decisions, to-do items, and problems I ran into that still linger:

* Relating to npm:
  * `npm audit` shows 7 problems, but they're all either because of (or upstream of) `elm-webpack-loader`.
  * `elm-css-modules-loader` expects `webpack < 4`, but it works fine with 4; please ignore the warning.

* Program structure:
  * `Api.Json` is kind of a mess, but there's enough crossover between both Survey types and generic decoders that it's fine... ish... for the moment.
  * `Data.Survey`'s `Question a` is a record type that's extensible, to represent bare server-provided question data, but also allow for annotation to represent different UI states. I wanted to have each question be able to be opened (a "breakdown" of answers, with a bar-chart animation that fires on the first time you open the panel), but I didn't have time to implement it and wire it all in. The types hang around as example extension points.

* Tests
  * The tests are mostly of the "round-trip a data structure through encoder+decoder functions" variety, eg. the routing and JSON tests; admittedly these round-trip fuzzers *are* useful in flushing out silly mistakes, but I'd prefer more.
  * The JSON decoder tests are incomplete; they only test the "index" JSON, and are intended as an example of what round-trip fuzzers look like.
  * There are, at least, example-based tests for the easy pure functions (`Data.Survey.Stats`).
  * There are no UI functionality tests, which can go pear-shaped even if your types line up; I had a "compiling but not working" UI when hooking up the API-loading functions the first time around.

* Documentation
  * There is way less documentation in this that I'd like. I've tried to make the types as self-documenting as I can manage (eg. encoding assumptions, having transforms like `SurveyFromApi -> SurveyForUI`), but I haven't at all had the time to give this the comments (outside these notes) that I'd like.
