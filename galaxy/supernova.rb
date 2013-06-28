Supernova.create :star => :supernova, :requires => [:posix] do
  on :install_stars, :requires => [:git_repo] do |opts|
    Dir.mkdir(Dir.home + "./galaxy") rescue nil

    unless opts[:install_path]
      opts[:install_path] = File.absolute_path(Dir.home + "/.galaxy/" + File.basename(opts[:git_repo], ".git"), __FILE__)
    end

    result = line("git", "clone {repo} {dest}").pass(:repo => opts[:git_repo], :dest => opts[:install_path])

    Supernova.logger.info { "Git Result: #{result.stdout + result.stderr}" }
  end
end
