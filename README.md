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





#### To run all JavaScript bundling tasks

    rake lash:js  

#### To bundle application scripts

    rake lash:js_bundle
    
#### To minify all cdn, and on-demand JavaScript files

    rake lash:js_min




## CSS Sprites

## Integrating With Capistrano

 