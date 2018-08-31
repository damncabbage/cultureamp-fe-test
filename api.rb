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

  def error_json(msg)
    { error: msg }.to_json
  end

  error(400) { error_json('Bad input') }
  error(404) { error_json('Not found') }
  error(500) { error_json('Server error') }

  # This should never go in a production server, but I'm adding
  # it here for Fun Time testing opportunities.
  if ENV['FLAKEOUT']
    before do
      flake = -> (msg) {
        out = "!!! FLAKEOUT: #{msg} !!!"
        puts ("!" * out.length)
        puts out
        puts ("!" * out.length)
      }
      case rand(1..3)
      when 1
        flake.call "Sleeping..."
        sleep 3
      when 2
        flake.call "Erroring..."
        raise "Server is flaking out..."
      when 3
        flake.call "Fine! This time."
      end
    end
  end
end
