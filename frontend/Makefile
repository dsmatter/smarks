PUBLIC_DIR=../public
ASSETS_DIR=assets
COMPONENTS_DIR=$(ASSETS_DIR)/components
STYLE_DIR=style
SCRIPT_DIR=script

JS_ASSETS=$(COMPONENTS_DIR)/jquery/jquery.min.js \
          $(COMPONENTS_DIR)/jquery-ui/ui/minified/jquery-ui.min.js \
          $(ASSETS_DIR)/jquery.showLoading.min.js \
          $(COMPONENTS_DIR)/es5-shim/es5-shim.min.js \
          $(COMPONENTS_DIR)/es5-shim/es5-sham.min.js \
          $(COMPONENTS_DIR)/flight/build/flight.js \
          $(COMPONENTS_DIR)/underscore/underscore-min.js \
          $(COMPONENTS_DIR)/bootstrap/docs/assets/js/bootstrap.min.js \
          $(COMPONENTS_DIR)/requirejs/require.js

CSS_ASSETS=$(COMPONENTS_DIR)/bootstrap/docs/assets/css/bootstrap.css \
		       $(COMPONENTS_DIR)/jquery-ui/themes/cupertino/jquery-ui.min.css \
           $(ASSETS_DIR)/showLoading.css

compile: compile_style compile_script

compile_script: $(SCRIPT_DIR)/*.coffee
	coffee -c -o $(PUBLIC_DIR)/js $(SCRIPT_DIR)

compile_style: $(STYLE_DIR)/*.scss
	scss --update $(STYLE_DIR)
	mv $(STYLE_DIR)/*.css $(PUBLIC_DIR)/css

assets: js_assets css_assets

js_assets: $(JS_ASSETS)
	uglifyjs $(JS_ASSETS) > $(PUBLIC_DIR)/js/assets.min.js

css_assets: $(CSS_ASSETS)
	cat $(CSS_ASSETS) | cleancss > $(PUBLIC_DIR)/css/assets.min.css
