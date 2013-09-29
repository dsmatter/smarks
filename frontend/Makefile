# Needed NPM binaries
BIN_DIR=node_modules/.bin
COFFEE=$(BIN_DIR)/coffee
SCSS=$(BIN_DIR)/node-sass
UGLIFYJS=$(BIN_DIR)/uglifyjs
RJS=$(BIN_DIR)/r.js
CLEANCSS=$(BIN_DIR)/cleancss

PUBLIC_DIR=../public
BUILD_DIR=build
ASSETS_DIR=assets
COMPONENTS_DIR=$(ASSETS_DIR)/components
STYLE_DIR=style
SCRIPT_DIR=script

JS_ASSETS=$(COMPONENTS_DIR)/jquery/jquery.min.js \
          $(COMPONENTS_DIR)/jquery-ui/ui/minified/jquery-ui.min.js \
          $(COMPONENTS_DIR)/jquery.showLoading.min.js \
          $(COMPONENTS_DIR)/es5-shim/es5-shim.min.js \
          $(COMPONENTS_DIR)/es5-shim/es5-sham.min.js \
          $(COMPONENTS_DIR)/flight/build/flight.js \
          $(COMPONENTS_DIR)/underscore/underscore-min.js \
          $(COMPONENTS_DIR)/bootstrap/docs/assets/js/bootstrap.min.js \
          $(COMPONENTS_DIR)/requirejs/require.js

CSS_ASSETS=$(COMPONENTS_DIR)/bootstrap/docs/assets/css/bootstrap.css \
		       $(COMPONENTS_DIR)/jquery-ui/themes/cupertino/jquery-ui.min.css \
           $(COMPONENTS_DIR)/showLoading.css

all: assets compile minify package install clean

assets: js_assets css_assets
compile: compile_style compile_script
minify: minify_style minify_script
package: package_script

compile_script: $(SCRIPT_DIR)/*.coffee
	mkdir -p $(BUILD_DIR)/js
	$(COFFEE) -c -o $(BUILD_DIR)/js $(SCRIPT_DIR)

compile_style: $(STYLE_DIR)/*.scss
	mkdir -p $(BUILD_DIR)/css
	$(SCSS) $(STYLE_DIR)/style.scss $(BUILD_DIR)/css/style.css

js_assets: $(JS_ASSETS)
	mkdir -p $(BUILD_DIR)/js
	$(UGLIFYJS) $(JS_ASSETS) > $(BUILD_DIR)/js/assets.min.js

css_assets: $(CSS_ASSETS)
	mkdir -p $(BUILD_DIR)/css
	cat $(CSS_ASSETS) | $(CLEANCSS) > $(BUILD_DIR)/css/assets.min.css

minify_script:
	$(RJS) -o baseUrl=$(BUILD_DIR)/js/rjs name=../user out=$(BUILD_DIR)/js/user.js;
	$(RJS) -o baseUrl=$(BUILD_DIR)/js/rjs name=../overview out=$(BUILD_DIR)/js/overview.js
	rm -rf $(BUILD_DIR)/js/rjs

minify_style:
	$(CLEANCSS) -o $(BUILD_DIR)/css/style.css $(BUILD_DIR)/css/style.css

package_script:
	$(UGLIFYJS) -o $(BUILD_DIR)/js/overview.js $(BUILD_DIR)/js/assets.min.js $(BUILD_DIR)/js/overview.js
	$(UGLIFYJS) -o $(BUILD_DIR)/js/user.js $(BUILD_DIR)/js/assets.min.js $(BUILD_DIR)/js/user.js

install:
	cp -r $(BUILD_DIR)/js $(PUBLIC_DIR)
	cp -r $(BUILD_DIR)/css $(PUBLIC_DIR)

clean:
	rm -rf $(BUILD_DIR)
