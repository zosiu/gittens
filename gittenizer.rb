class Gittenizer
  attr_reader :repo, :github

  def initialize(repo, github)
    @repo = repo
    @github = github
  end

  def priority(apt)
    case apt
    when 'full' then 0
    when 'satiated' then 0
    when 'hungry' then 3
    when 'very hungry' then 4
    when 'starving' then 4
    when 'hibernating' then 5
    when 'comatose' then 5
    when 'sleepy' then 5
    when 'calm' then 0
    when 'alert' then 0
    when 'playful' then 2
    when 'hyperactive' then 2
    when 'newborn' then 2
    when 'kitten' then 1
    when 'teen' then 0
    when 'adult' then 0
    when 'senior' then 2
    when 'black' then 3
    when 'bicolor' then 1
    when 'tabby' then 0
    when 'nyan' then 1
    when 'amazing technicolor' then 3
    when 'skinny' then 1
    when 'chubby' then 0
    when 'fat' then 2
    when 'slightly amused' then 0
    when 'amused' then 1
    when 'cheshire' then 2
    else 0
    end
  end

  def gitten
    @gitten ||= { name: info[:full_name],
                  maturity: maturity,
                  activity: activity,
                  size: size,
                  contributor_diversity: contributor_diversity,
                  amusement: amusement,
                  hunger: hunger }
  end

  def sorted_apts
    gitten.values.sort_by { |apt| priority(apt) }.reverse
  end

  def summary
    "#{sorted_apts.first(2).join(' ')} gitten"
  end

  def to_ascii
    '(=ↀωↀ=)'
  end

  def badge_color
    'blue'
  end

  def badge_url
    'https://img.shields.io/badge/' + CGI::escape("#{summary.gsub(/\s/, '_')}-#{to_ascii}-#{badge_color}.svg")
  end

  def hunger
    case hunger_number
    when 0..2 then 'full'
    when 3..5 then 'satiated'
    when 6..8 then 'hungry'
    when 9..11 then 'very hungry'
    when 12..14 then 'near starving'
    else 'starving'
    end
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

  def open_issues_last_period
    @open_issues_last_period ||= issue_count 'open', 42
  end

  def closed_issues_last_period
    @closed_issues_last_period ||= issue_count 'closed', 42
  end

  def open_issues
    info[:open_issues]
  end

  def participation_stats
    # hackish, but somehow sometimes it's nil who knows why...
    until @participation_stats
      @participation_stats ||= github.participation_stats(repo)
    end

    @participation_stats
  end

  private

  def issue_count(is, days = 30)
    q = "repo:#{info[:full_name]} is:#{is} created:>=#{Date.today - days}"
    GITHUB.search_issues(q)[:total_count]
  end

  def info
    # TODO: handle moved repos somehow
    @info ||= github.repository repo
    fail 'Not a valid repository' unless @info[:full_name]

    @info
  end

  def contributor_count
    @contributor_count ||= github.contributors(repo, true, per_page: 101).count
  end

  def commit_activity_number
    stats = participation_stats[:all].reverse
    last_week = stats[0]
    last_month = stats[0..4].inject(0, :+)
    last_two_months = stats[0..8].inject(0, :+)
    last_three_months = stats[0..12].inject(0, :+)
    last_half_year = stats[0..24].inject(0, :+)

    (last_week + last_month / 4.0 + last_two_months / 8.0 + last_three_months / 16.0 + last_half_year / 32.0) * 10
  end

  def hunger_number
    return 0 if open_issues.zero?

    if open_issues_last_period.zero?
      open_issues > 3 ? open_issues / closed_issues_last_period.to_f : 6
    else
      diff = closed_issues_last_period - open_issues_last_period
      if diff > 0
        (open_issues / diff).ceil
      else
        per = (0.999999 - closed_issues_last_period / open_issues_last_period.to_f).abs
        Math.log(0.02, per).ceil
      end
    end
  end
end
