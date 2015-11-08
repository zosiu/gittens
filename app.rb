require './environment'

Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'

module ExampleRepoHelper
  def example_gitten
    example_repo = ['thoughtbot/paperclip', 'refile/refile', 'carrierwaveuploader/carrierwave'].sample
    @example_gitten ||= Gittenizer.new(example_repo, GITHUB).gitten
  end
end

Cuba.plugin ExampleRepoHelper

Cuba.define do
  on get do
    on param('screenshot') do
      res.write partial('screenshot')
    end

    on 'random-gitten' do
      begin
        repo = GITHUB.search_repos("forks:<=#{rand(100)}")[:items][rand(30)][:full_name]
        res.redirect '/gitten/' + repo
      rescue Octokit::Error => e
        @error = e.message
        @repo = repo || 'undefined-random-repo'
        res.write partial('gittens')
      end
    end

    on 'gitten/:owner/:repo' do |owner, repo|
      begin
        @gitten = Gittenizer.new("#{owner}/#{repo}", GITHUB).gitten
        res.write partial('gitten')
      rescue Octokit::Error => e
        @error = e.message
        @repo = "#{owner}/#{repo}"
        res.write partial('gittens')
      end
    end

    on 'badge/:owner/:repo' do |owner, repo|
      begin
        badge_url = Gittenizer.new("#{owner}/#{repo}", GITHUB).badge_url
        res.redirect badge_url
      rescue Octokit::Error => e
        @error = e.message
        res.redirect 'https://img.shields.io/badge/error,_please_refresh-' + CGI::escape('٩(ↀДↀ)۶') +  '-red.svg'
      end
    end

    on 'ohai' do
      @example = example_gitten
      res.write partial('gittens')
    end

    on true do
      res.redirect '/ohai'
    end
  end
end
