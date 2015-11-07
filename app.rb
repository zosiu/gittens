require './environment'

Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'

Cuba.define do
  on get do
    on 'random-gitten' do
      begin
        repo = GITHUB.search_repos("forks:<=#{rand(100)}")[:items][rand(30)][:full_name]
        res.redirect '/gitten/' + repo
      rescue => e
        @error = e.message
        @repo = repo || 'undefined-random-repo'
        res.write partial('gittens')
      end
    end

    on 'gitten/:owner/:repo' do |owner, repo|
      begin
        @gitten = Gittenizer.new("#{owner}/#{repo}", GITHUB).gitten
        res.write partial('gitten')
      rescue => e
        @error = e.message
        @repo = "#{owner}/#{repo}"
        res.write partial('gittens')
      end
    end

    on 'badge/:owner/:repo' do |owner, repo|
      res.redirect Gittenizer.new("#{owner}/#{repo}", GITHUB).badge_url
    end

    on 'ohai' do
      example_repo = ['thoughtbot/paperclip', 'refile/refile', 'carrierwaveuploader/carrierwave'].sample
      @example_gitten = Gittenizer.new(example_repo, GITHUB).gitten
      res.write partial('gittens')
    end

    on true do
      res.redirect '/ohai'
    end
  end
end
