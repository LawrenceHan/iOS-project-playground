namespace :fancybox do
  desc "copy kindeditor into public folder"
  task :assets do
    puts "copying fancybox images into public/assets folder ..."
    target_path = Rails.public_path.join('assets')
    source_path = "#{Rails.root}/vendor/assets/images/."
    FileUtils.mkdir_p target_path
    FileUtils.cp_r source_path, target_path
  end
end
