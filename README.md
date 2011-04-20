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

    rake lash:all                   # Runs all lash tasks including javascripts and style sheets
    rake lash:deploy                # Called by capistrano to generate static assets on the server

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

Shared CDN hosts are great for optimizing your site's user experience but there are two issues that developers regularly have to deal with - developing offline and accounting for CDN unavailability. Lash handles both of these cases with ease.

During development, Lash will use the copies of the libraries found in your public/javascripts/cdn directory. This makes it easy to work offline.

In production, Lash will use the CDN versions of the scripts and if a runtime test is provided, fallback to the local version if the CDN is unavailable.

    <%= javascript_cdn 'jquery', '//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js', 'jQuery' -%>
   
    # => <script src="//ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js" type="text/javascript"></script>
    # => <script type="text/javascript">
    # =>  if(typeof jQuery === "undefined" ) 
    # =>    document.write( unescape("<script src=\"/javascripts/cdn/jquery.min.js?1297459967\" type=\"text/javascript\"><\/script>") );
    # => </script>

### Referencing JavaScript Bundles in Layouts

To include references to bundled scripts in a view simply call {Lash::BundleHelper#javascript_bundle}

#### Example
    <%= javascript_bundle 'application', 'ie' %>
    
When {Lash::BundleHelper#bundle_files?} is true (on by default in production), lash will include a reference to the single bundled script. When false, it will include each individual javascript that would have been bundled.

See {Lash::BundleHelper#javascript_bundle} for details.

### application.bundleVersion.js

When referring to assets in your javascripts you loose the convenience of the rails cache busting asset tags. During bundling, lash will generate an `public/javascripts/application/application.bundleVersion.js` which gets bundled into the application script. This script simply declares a global variable `bundleVersion` which you can append to asset urls in your scripts.

#### Example
  
    $('#waiting-div').append( $('<img src="/images/wainting.gif?' + bundleVersion + '" />' ) )

### JavaScript bundling tasks

    rake lash:js                    # Bundles and minifies javascripts
    rake lash:js_bundle             # Bundles javascripts folders into single minified files
    rake lash:js_gzip               # Compresses minified javascripts for nginx gzip_static support
    rake lash:js_min                # Minifies all javascripts

## CSS Sprites



### _version.scss

When referring to assets in your css scripts you loose the convenience of the rails cache busting asset tags. During bundling, lash will generate an `public/stylesheets/sass/_version.scss`. You can include this into any of your SASS scripts when you reference static assets like images. 

#### Example

    @import 'version';
    .smiley { background-image: url(/images/smiley.png?#{$bundle-version})}
    


### CSS bundling tasks

    rake lash:css        # Process CSS scripts
    rake lash:css_gzip   # Compresses stylesheets for use with nginx gzip_static
    rake lash:sass       # Pre-generate sass scripts
    rake lash:sprites    # Generate CSS sprites from the public/sprites folders

## Optimizing PNG Images

Most image editors will compress PNG files using a very basic compression algorithm. However the PNG format 
allows for much more aggressive optimization at the cost of speed. Since image resources are some of the
heaviest assets downloaded from your site, optimizing them is often worth the effort.

See [A guide to PNG optimization](http://optipng.sourceforge.net/pngtech/optipng.html) for a more detailed discussion.

#### To optimize your pngs

    rake lash:png

## Integrating With Capistrano

Lash was designed to work with capistrano to easily run static asset bundling during the deployment process. This makes 
sure that all assets are primed for static serving from your website without interfering with any existing requests
that are currently being served.

#### To run bundling tasks during deployment

    # in config/deploy.rb
    require 'lash/capistrano'
 
If you use capistrano to publish your app (and really who isn't?) you'll want to add some additional filters to your .gitignore file

    # lash asset helpers
    public/javascripts/common/application.bundleVersion.js
    public/stylesheets/sass/_version.scss
    
    # lash generated filed
    public/javascripts/bundle_*.js
    public/stylesheets/*.css
    public/stylesheets/sass/_*-sprite.scss
    public/javascripts/**/*.min.js
 
 
## License

### Lash

Copyright (C) 2011 Apps In Your Pants.

Dual licensed under MIT and GPLv3


### Google Closure Compiler

Copyright 2009 The Closure Compiler Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



### Optipng

Copyright (C) 2001-2011 Cosmin Truta.

This software is provided 'as-is', without any express or implied
warranty.  In no event will the author(s) be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software.  If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not
   be misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
