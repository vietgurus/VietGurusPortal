# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

# Precompile additional assets.
# application.js.coffee, application.css.scss, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( session.css )
Rails.application.config.assets.precompile += %w( session.js )
Rails.application.config.assets.precompile += %w( 404.html )
Rails.application.config.assets.register_mime_type('text/html', '.html')
