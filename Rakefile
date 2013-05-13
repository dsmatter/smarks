#!/usr/bin/env rake

### Dirs and files

public_dir = File.expand_path('../public', __FILE__)
js_dir     = File.join(public_dir, 'js')
js_order   = ['jquery-1.7.2.min.js', 'jquery-ui.min.js', 'jquery-ui-timepicker-addon.js',
							'jquery.showLoading.min.js', 'bootstrap.min.js', 'overview.js']
js_all     = 'all.min.js'

css_dir    = File.join(public_dir, 'css')
css_all    = 'all.min.css'

### Helper

def shell(cmd)
	puts cmd
	system cmd
end

### Tasks

task :default => :production

desc 'Minify js files'
task :minify_js do
	closure_cmd_prefix = 'uglifyjs'
	cmd = '%s %s > %s' % [
		closure_cmd_prefix,
		js_order.map { |fn| '"' + File.join(js_dir, fn) + '"' }.join(' '),
		File.join(js_dir, js_all)
	]
	puts cmd
	system(cmd)
end

desc 'Unminify js files'
task :unminify_js do
	open(File.join(js_dir, js_all), 'w') do |f|
		js_order.each do |fn|
			f.puts "document.write('<script src=\"/js/#{fn}\"></script>');"
		end
	end
end

desc 'Compile SASS files'
task :compile_sass do
	Dir[File.join css_dir, '*.scss'].each do |fn|
		out_fn = "#{fn.chomp(File.extname fn)}.css"
		cmd = "sass \"#{File.expand_path fn}\" > \"#{File.expand_path out_fn}\""
		puts cmd
		system cmd
	end
end

desc 'Minify css files'
task :minify_css => [:compile_sass] do
	cmd = "cat #{css_dir}/*.css | cleancss -o #{File.join css_dir, css_all}"
	puts cmd
	system cmd
end

desc 'Unminify css files'
task :unminify_css => [:compile_sass] do
	open(File.join(css_dir, css_all), 'w') do |f|
		Dir[File.join css_dir, '*.css'].each do |fn|
			next if fn =~ /\/all\.min\.css/
			f.puts "@import \"/css/#{File.basename fn}\";"
		end
	end
end

desc 'Change to production environment'
task :production => [:minify_js, :minify_css] do
end

desc 'Change to development environment'
task :development => [:unminify_js, :unminify_css] do
end

desc 'Start SASS -> CSS transforming'
task :livecss do
	shell "sass --watch #{css_dir}/newstyle.scss"
end
