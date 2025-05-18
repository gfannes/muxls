require('fileutils')

here_dir = File.dirname(__FILE__)
gubg_dir = ENV['gubg']
gubg_bin_dir = File.join(gubg_dir, 'bin')

task :default do
    sh 'rake -T'
end

desc 'Install'
task :install, :variant do |_task, args|
    mode = :safe
    # mode = :fast
    # mode = :debug

    mode_str = mode == :debug ? '' : "--release=#{mode}"
    sh("zig build install #{mode_str} --prefix-exe-dir #{gubg_bin_dir}")
end

desc 'Run all UTs'
task :ut, %i[filter] do |_task, args|
    filter = (args[:filter] || '').split(':').map { |e| "-Dtest-filter=#{e}" } * ' '
    sh "zig build test #{filter}"
end

desc('Clean')
task :clean do
    FileUtils.rm_rf('zig-out')
end
