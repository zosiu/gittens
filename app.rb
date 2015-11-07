require './environment'

Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'

Cuba.define do
  on get do
    on 'random-gitten' do
      repo = GITHUB.search_repos("forks:<=#{rand(100)}")[:items][rand(30)][:full_name]
      res.redirect '/gitten/' + repo
    end

    on 'gitten/:owner/:repo' do |owner, repo|
      @gitten = Gittenizer.new("#{owner}/#{repo}", GITHUB).gitten
      res.write partial('gitten')
    end

    on 'badge/:owner/:repo' do |owner, repo|
      res.redirect Gittenizer.new("#{owner}/#{repo}", GITHUB).badge_url
    end

    on 'ohai' do
      @debug = Gittenizer.new('rails/rails', GITHUB).gitten
      res.write partial('gittens')
    end

    on root do
      res.redirect '/ohai'
    end
  end
end
