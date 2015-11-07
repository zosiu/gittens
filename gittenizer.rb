class Gittenizer
  attr_reader :repo, :github, :info

  def initialize(repo, github)
    @repo = repo
    @github = github
  end

  def info
    @info ||= github.repository repo
  rescue StandardError => e
    { error: e.message }
  end
end
