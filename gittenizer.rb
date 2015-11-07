class Gittenizer
  attr_reader :repo, :github

  def initialize(repo, github)
    @repo = repo
    @github = github
  end

  def gitten
    { maturity: maturity,
      contributor_diversity: contributor_diversity }
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

  def contributor_diversity
    case contributor_count
    when 1 then 'black'
    when 2 then 'bicolor'
    when 3 then 'calico'
    when 4...50 then 'tabby'
    when 50...100 then 'nyan'
    else 'amazing technicolor'
    end
  end

  private

  def info
    # TODO: handle moved repos somehow
    @info ||= github.repository repo
  end

  def contributor_count
    @contributor_count ||= github.contributors(repo).count
  end
end
