class Gittenizer
  attr_reader :repo, :github

  def initialize(repo, github)
    @repo = repo
    @github = github
  end

  def gitten
    { name: info[:full_name],
      maturity: maturity,
      contributor_diversity: contributor_diversity,
      size: size,
      amusement: amusement,
      activity: activity }
  end

  def activity
    case commit_activity_number
    when 0 then 'hibernating'
    when 1...10 then 'comatose'
    when 10...30 then 'sleepy'
    when 30...50 then 'calm'
    when 50...100 then 'alert'
    when 100...200 then 'playful'
    else 'hyperactive'
    end
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

  def size
    case info[:size] / 1000
    when 0...40 then 'skinny'
    when 40...100 then 'chubby'
    else 'fat'
    end
  end

  def amusement
    case info[:stargazers_count] + info[:watchers_count] * 1.2
      when 0...100 then 'slightly amused'
      when 100...1000 then 'amused'
      else 'cheshire'
    end
  end

  private

  def info
    # TODO: handle moved repos somehow
    @info ||= github.repository repo
  end

  def contributor_count
    @contributor_count ||= github.contributors(repo, true, per_page: 101).count
  end

  def participation_stats
    @participation_stats ||= github.participation_stats(repo)[:all].reverse
  end

  def commit_activity_number
    last_week = participation_stats[0]
    last_month = participation_stats[0..4].inject(0, :+)
    last_two_months = participation_stats[0..8].inject(0, :+)
    last_three_months = participation_stats[0..12].inject(0, :+)
    last_half_year = participation_stats[0..24].inject(0, :+)

    (last_week + last_month / 2.0 + last_two_months / 4.0 + last_three_months / 8.0 + last_half_year / 16.0) * 10
  end
end
