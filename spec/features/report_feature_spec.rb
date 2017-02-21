require 'rails_helper'

# include WaitForAjax

RSpec.describe "Generating a client report", type: :feature do

  before do
    @client = FactoryGirl.create(:client, 
                            name: "DMU Leicester Castle Business School")
    @client_channel = FactoryGirl.create(:client_channel, 
                                    type: "Facebook", 
                                    uid: "1376049629358567",
                                    client: @client)
    @campaign = FactoryGirl.create(:campaign, 
                        name: "2017_interview_remarketing_promoted_posts",
                        client: @client)
    @campaign_channel = FactoryGirl.create(:campaign_channel, 
                                    campaign: @campaign, 
                                    client_channel: @client_channel, 
                                    uid: "6065738876478")
  end

  context "should" do

    it "summarise the search terms" do
      search_url = reports_path(client: @client.id, campaign: @campaign.id, channel: ['ClientChannels::Facebook'], date_from: '2017-02-13', date_to: '2017-02-20')
      visit search_url
      expect(page).to have_content @client.name
      expect(page).to have_content @campaign.name
    end
  end
end