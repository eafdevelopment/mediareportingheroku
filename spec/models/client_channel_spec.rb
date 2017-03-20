require 'rails_helper'

RSpec.describe ClientChannel do

  describe '#nice_name' do
    it 'works' do
      expect(ClientChannels::Facebook.new.nice_name).to eq('Facebook')
    end
  end

  describe '#before destroy' do
    it 'checks if any datasets are generating' do
      dmu = Client.new(name: 'DMU Intl', google_analytics_view_id: "90647904")
      dmu.save
      dmu.client_channels.create(type: 'ClientChannels::Adwords', uid: '752-213-4824')
      dmu_adwords = dmu.client_channels.find_by(type: 'ClientChannels::Adwords')
      Dataset.create(client_channel_id: dmu_adwords.id, status: 'generating', title: 'DMU_Adwords.csv')

      expect { dmu_adwords.destroy }.to change { dmu.client_channels }.by([])
    end
  end

end
