fs = require 'fs'
Path = require 'path'

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'phoenix-migrations-navigation:latest': => @latest()

  latest: ->
    # use only first root directory
    dir = atom.project.getDirectories()[0]

    if @isPhoenixDir(dir)
      latest_migration_path = @getLatestMigration(dir)
      if latest_migration_path
        atom.workspace.open(latest_migration_path)
      else
        alert "Could not find any migrations in your priv/repo/migrations directory. Please add some and try again."
    else
      alert "This doesn't look like a Elixir project. Please open up the root of a Elixir app and try again."

  isPhoenixDir: (dir) ->
    expected_phoenix_files = ['lib', 'priv', 'web', 'mix.exs']
    entries = dir.getEntriesSync()
    matching_dirs = []

    entries.forEach (entry) ->
      if expected_phoenix_files.indexOf(entry.getBaseName()) > -1
        matching_dirs.push(entry)

    return expected_phoenix_files.length == matching_dirs.length

  getMigrationsDir: (dir) ->
    Path.join(dir.getPath(), 'priv', 'repo', 'migrations')

  getLatestMigration: (dir) ->
    migrations_dir = @getMigrationsDir(dir)
    migrations = fs.readdirSync(migrations_dir).filter (elem) ->
      stat = fs.statSync(Path.join(migrations_dir, elem))
      return stat.isFile()

    if migrations.length
      Path.join(migrations_dir, migrations[migrations.length-1])
