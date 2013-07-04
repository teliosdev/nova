Supernova star: :steamcmd do

  to :install, on: :posix do |opts|
    # TODO
    grab_file "http://media.steampowered.com/client/steamcmd_linux.tar.gz", decompress: true,
      to: options[:steamcmd_install_directory]

    # TODO
    cd to: options[:steamcmd_install_directory]
    line("./steamcmd.sh", "+login anonymous +quit").run

    check_install_libraries if bits == 64
  end

  to :install, on: :windows do
    # TODO
    grab_file "http://media.steampowered.com/client/steamcmd_win32.zip", decompress: true,
      to: options[:steamcmd_install_directory]

    # TODO
    cd to: "./steamcmd"
    line("steamcmd", "+login anonymous +quit").run
  end

  to :exec, defaults: { username: "anonymous", password: "" } do |opts|
    username, password = opts.delete(:username), opts.delete(:password)
    l = line("#{options[:steamcmd_install_directory]}/steamcmd#{'.sh' if posix?}",
      "+login :username :password #{convert_hash(opts)} +quit")

    l.run(username: username, password: password)
  end

  to :install_game, requires: [:install_dir, :app] do |opts|
    app = opts.delete(:app)
    app = data(:app_ids)[app] if app.is_a? Symbol

    run!(:exec, {
      force_install_dir: opts.delete(:install_dir),
      app_update: "#{app} validate"
    }.merge(opts))
  end

  with_options do
    require_options :steamcmd_install_directory
  end

  # TODO
  #data :app_ids do
  #  {
  #    cs_go: 740,
  #    gmod: 4020,
  #    nuclear_dawn: 111710,
  #    red_orch: 223240,
  #    red_orch2: 212542,
  #    rising_storm: 212542,
  #    tf2: 232250,
  #    tf2_beta: 229830,
  #    dod_source: 232290,
  #    cs_source: 232330,
  #    hl2_dm: 232370,
  #    ship: 2403,
  #    sam: 41080
  #  }
  #end

  private

  def check_install_libraries
    # TODO
    install_packages ubuntu: ["ia32-libs"],
      red_hat: ["glibc.i686", "libstdc++.i686"],
      arch: ["lib32-gcc-libs"]
  end

  def convert_hash(hash)
    data = hash.to_a

    data.map do |ary|
      ary.map { |x| "+#{x[0]} #{x[1]} " }
    end
  end

end
