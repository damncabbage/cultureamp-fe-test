require File.expand_path '../spec_helper.rb', __FILE__

describe "Survey API app" do
  specify "index" do
    get '/', 'CONTENT_TYPE' => 'application/json'

    expect(last_response).to be_ok
    expect(
			JSON.parse(last_response.body)['survey_results'][0]['name']
		).to_not be_nil
  end

	[
		["1", "Simple Survey"],
		["2", "Acme Engagement Survey"],
	].each do |(id, name)|
		["", ".json"].each do |ext|
			specify "survey #{id}#{ext} (#{name})" do
				get "/survey_results/#{id}#{ext}", 'CONTENT_TYPE' => 'application/json'

				expect(last_response).to be_ok
				expect(
					JSON.parse(last_response.body)['survey_result_detail']['name']
				).to eq(name)
			end
		end
	end

  specify "non-existent survey" do
    get '/survey_results/3.json', 'CONTENT_TYPE' => 'application/json'

    expect(last_response).to be_not_found
  end
end
