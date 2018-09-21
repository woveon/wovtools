# Config Management

TODO: 
Redoing how the json is manages and configuration is managed with wovtools. Too many levels of indirection.

- See [this github issue](https://github.com/woveon/wovtools/issues/24) for the history.

## Operations - in order of passes

0. merge all files into one JSON file.

1. grafting - swap in one route for another (ex. for local operation)
  - uses wovtools/config.json stagemod (rename to grafts) settings
  - `{plem : {local : {db_url : "localhost"}, STAGE:cw : {db_url : "plemdb-cw-mongodb", urlscheme : "https"}}}`
    - this after STAGE select would leave plem.cw.\* and plem.local.\*
  - grafting rule: `[plem.local,plem.STAGE:cw]` would swap local into cw, keeping all other cw, and removing local
    - `{plem : {STAGE:cw : {db_url : "localhost", urlscheme : "https"}}}`


2. STAGE select - Select between configuration options, specific to a particular stage of development. Completely collapses down
  - NOTE: retain stages, so commands like database and such still have access to old commands, but don't make variables out of them
  - `{plugin.plem: {"STAGE:cw: {dburl : "plemdb-cw-mongo"}}}` -> `{plugin.plem : {dburl : "plemdb-cw-mongo", STAGE: {cw: {dburl : "plemdb-cw-mongo"}}}}`
  - this would make env var : `export WOV__plugin__db_url=plemdb-cw-mongo`


3. specialization/instance - a known concept to the code (ex. "plugin", "microservice", "ms") is specialized to be an instance.
  - "plugin.plem" - in plugin code, we apply the "plem" plugin config to the plugin.
  - so `{"plugin.plem" : {id :7}}` would create `{"plugin" : {id : 7}}`, and eventually `export WOV_plugin_id=7`.


## Transform to Env Vars

- start "WOV"
- dots -> `__`
- STAGE - trim
- dot in key, should not have -> error

```
plugin.id -> WOV__plugin__id

```

## access to out-of-stage vars

Useful for things like accessing databases so you don't have to rebuild.

- plugin.STAGE.cw.password instead of plugin.password


## No more config.[sc]8s files. 
- this would impact how many scripts operate
- probably keep these since used in k8s config and many options require a mix of config and ordering (i.e. URLs with schema and such)

## json to env
- do at runtime? maybe not too slow
- only used for running scripts and such


## Get rid of Config object? in code?
- I like the object as it centralizes all config and you know everything it will use
- I don't like having to manage it in its current form
- I don't like config having its own hierarchy that differs from ENV
- maybe make it have strings like "plugin.id" and at runtime it loads `WOV__plugin__id`, then validates . this becomes automated then
- ... think about this. maybe just l

