class Gittenizer
  attr_reader :repo, :github, :info

  def initialize(repo, github)
    @repo = repo
    @github = github
  end

  def gitten
    { maturity: maturity }
  end

  def maturity
    case (Date.today - info[:created_at].to_date).to_i
    when 0...2*30 then 'newborn'
    when 2*30...6*30 then 'kitten'
    when 6*30...356 then 'teen'
    when 356...4*356 then 'adult'
    else 'senior'
    end
  end

  private

  def info
    # TODO: handle moved repos somehow
    @info ||= github.repository repo
  end
end
