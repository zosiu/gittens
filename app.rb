require './environment'

Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'

Cuba.define do
  on get do
    on 'ohai' do
      @debug = Gittenizer.new('rails/rails', GITHUB).gitten
      res.write partial('gittens')
    end

    on root do
      res.redirect '/ohai'
    end
  end
end
