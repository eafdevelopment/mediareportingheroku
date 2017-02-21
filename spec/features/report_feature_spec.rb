require 'rails_helper'

RSpec.describe 'Generating a client report', type: :feature do

  before do
    @client = FactoryGirl.create(:client, 
                                name: 'DMU Leicester Castle Business School')
    @client_channel = FactoryGirl.create(:client_channel, 
                                    type: "Facebook", 
                                    uid: "1376049629358567",
                                    client: @client)
  end

  context 'should' do

    it 'work' do
      visit '/'
      puts @client
      puts @client_channel
      expect(page).to have_content 'Report Search'
    end
  end
end