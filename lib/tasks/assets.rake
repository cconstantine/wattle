
namespace :assets do
  task :generate_non_hash_assets => :environment do
    require 'fileutils'
    regexp = /-\w{32}((?:\.\w+)+)\Z/

    assets = File.join(Rails.root, 'public', Wattle::Application.config.assets.prefix, "**/*")
    Dir.glob(assets).each do |filename|
      next if File.directory?(filename)
      next unless match = regexp.match(filename)

      newfilename = filename.gsub(match[0], match[1])
      FileUtils.cp(filename, newfilename)
    end
  end

  task :remove_public_assets => :environment do
    FileUtils.rm_rf(Rails.root.join("public", "assets"))
  end
end
