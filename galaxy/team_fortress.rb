Supernova.create star: :team_fortress do

  #require_star :steamcmd

  to :install do
    star(:steamcmd).run!(
      :do_install,
      install_dir: options[:game_install_directory],
      app: star(:steamcmd).data(:app_ids)[:tf2]
    )

    create_user "tf-server",
      system: true,
      nologin: true
  end

  with_options do
    requires_option :game_install_directory
  end

end
