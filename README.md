# jekyll-tsc
The long lost [typescript][typescript] converter for [jekyll][jekyll] :blue_book:.

[jekyll]: https://github.com/jekyll/jekyll
[typescript]: https://www.typescriptlang.org/

## Description
This plugin tries to give you working typescript compilation in jekyll blogs
with as little needed configuration as possible. To that end, you can simply
run the below 2 install steps and jekyll will convert typescript to javascript
during it's build :smile:.

## Install
1. Install [typescript](https://github.com/microsoft/TypeScript). You can do
   this globally through `npm install -g typescript` or locally for your site.
   All that matters in regards to integration with this plugin is the `tsc`
   executable is in your `PATH` when your site is built.
2. Install this plugin. jekyll offers two ways to do this, you can either :
   * `gem install jekyll-tsc` and then add `jekyll-tsc` to the plugins group in your _config.yml
   * add `jekyll-tsc` to your Gemfile under the `:jekyll_plugins` group & then run `bundle install`.
3. optional run `tsc --init` to create an `tsconfig.json` file.

## Features
* front matter is optional, all typescript files are treated as if they have an
  implicit front matter block, when it's ommited.

## How it works.
This plugin at a high level, basically copies all rendered typescript files to a
temporary directory, calls `tsc` to compile them and then stores the result back
to the in memory file.

This isn't the most efficient method possible, but after some trial and error it's
what I landed on. See [design decisions](#design-decisions) for a cursory
explanation.

## Configuration
The default configuration is as follows:

```yaml
typescript:
  temp_dir: .typescript
  extensions: ['.ts', '.tsx']
  copy_ext: []
  command: ['tsc']
  cache: true
```

### `temp_dir`
is the temporary directory where compilation will take place. You'll also want to
add this directory to your `exclude` path.

### `extensions`
Typescript file extensions. Any files with these extensions will be marked by
typescript as they're encountered and then later compiled.

### `copy_ext`
Extra file extensions, that don't need to be compiled but are needed for compilation.
eg. plain javascript files which're looked for during typescript compilation.

### `command`
The command which is run to compile files. In general this should just be the path to
the `tsc` executable, however you're free to specify any command line flags you don't
want in your tsconfig.json file here; or to change the executable to one local to your
site directory, eg. in `node_modules`.

### `cache`
typescript compilation can really slow down build speeds when your site is being served.
This option enables a caching mechanism so typescript files are only compiled when the
source files they depend on have been modified.

This is done by calculating the md5 hash of each page being processed, and only rebuilding
when the hashes are unequal. What this in affect means is that javascript files are compiled
independently of other assets for your jekyll site.

If you face issues with changes not being reflected in your `_site` directory, try disabling
this option to see if the issue persists.

## Design Decisions
This section is only a concern for developers for this plugin.

### Temporary Directory
The reason for a temporary directory is twofold.

Liquid front matter blocks are a syntax violation in the typescript language.
Allowing modern javascript modules would have caused `tsc` to crash when
importing a file with frontmatter. The conclusion here is, we can only compile
the files once we've already rendered all of them.

My initial thought would be to record any typescript files as their encountered,
change their extension to `.js` and then compile them once they've been written
to the build directory. However I was unsure as to what to do at that point.

The files have already been written, should I delete all of the ones I haven't
checked alongside the erroneous one? what happens if jekylls caching mechanism
is active alongside `jekyll serve`? The more I thought on this, the more
complications I encountered. In the end, it just made more sense to compile the
files in a sandbox, prior to writing, to make sure jekyll can quit the build
before serving it.
