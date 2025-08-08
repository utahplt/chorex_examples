defmodule Mix.Tasks.Demo.Projection do
  @shortdoc "Run projection demo"
  @requirements ["loadpaths", "app.config"]

  use Mix.Task

  def run(_args) do
    ProjectionExample.show_projection()
  end
end
