require 'sinatra'

class SurveyAPI < Sinatra::Base
	set :data_folder, File.expand_path('data', __dir__)

  get '/', provides: 'json' do
    send_file File.expand_path(
			'index.json',
		  settings.data_folder
		)
  end

  get '/survey_results/:id(.json)?', provides: 'json' do |id_string|
    id = Integer(id_string) rescue halt(400)
    send_file File.expand_path(
      "#{id}.json",
			File.join(settings.data_folder, 'survey_results')
		)
  end
end
