require './environment'

Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'

Cuba.define do
  on get do
    on 'ohai' do
      @debug = GITHUB.repository? 'rails/rails'
      res.write partial('gittens')
    end

    on root do
      res.redirect '/ohai'
    end
  end
end
