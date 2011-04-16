# Lash

Tame your static assets without adding additional processing time on your server. Lash will

* Bundle multiple JavaScript files into a single minified script.
* Minify JavaScript files to be included on demand.
* Build SASS style sheets using "production" settings.
* Bundle loose PNG, GIF and JPEG files into a single CSS image sprite.
* Optimize PNG files to reduce size by  5%-35%.
* Generate static gzipped versions of static assets for use with nginx's `gzip_static` plugin. 

Based on ["Optimizing asset bundling and serving with Rails"](https://github.com/blog/551-optimizing-asset-bundling-and-serving-with-rails) at github.

## Installation

  	# Gemfile
  	gem 'lash'

## Bundling Assets

Lash includes several rake tasks to bundle loose, development versions of your static assets into minified and compressed versions. To bundle all assets simply run

    rake lash:all

Individual assets can be bundled on demand using their respective `lash:asset_type` tasks.

## JavaScript

Lash expects to find JavaScript assets as subfolders of the public/javascripts folder like so

* public/javascripts
  * cdn
  * demand
  * application
  * ie
  
For each folder that lash finds, it will bundle all the .js files found in that folder into a single `bundle_#{folder}.js` file in the `public/javascripts` folder. For example, the following structure...

* public/javascripts/application
  * application.js
  * utility.js
  * rails.js
  
...will be bundled and minified into `public/javascripts/bundle_application.js` and a gzipped version `bundle_application.js.gz` in the same folder.

### Special Folders

Lash recognizes two special folders: cdn and demand.

__public/javascripts/cdn__
:   Lash expects to find scripts that will normally be referenced via CDN (like the jquery via google's cdn) for local use during development mode and to support outages on the CDN.

__public/javascripts/demand__
:   Lash will not bundle scripts in the demand folder. Instead, each script is individually minified and gzipped in place. This is where you would put large scripts that you don't use on every page - like jquery.forms.

### CDN JavaScripts and Developer Mode


### Referencing JavaScript Bundles in Layouts

To include references to bundled scripts in a view simply call {Lash::BundleHelper#javascript_bundle}

#### Example
    <%= javascript_bundle 'application', 'ie' %>
    
When {Lash::BundleHelper#bundle_files?} is true (on by default in production), lash will include a reference to the single bundled script. When false, it will include each individual javascript that would have been bundled.

See {Lash::BundleHelper#javascript_bundle} for details.



#### To run all JavaScript bundling tasks

    rake lash:js  

#### To bundle application scripts

    rake lash:js_bundle
    
#### To minify all cdn, and on-demand JavaScript files

    rake lash:js_min




## CSS Sprites

## Integrating With Capistrano

 