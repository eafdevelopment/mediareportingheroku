require 'rails_helper'

RSpec.describe ClientChannel do

  describe '#nice_name' do
    it 'works' do
      expect(ClientChannels::Facebook.new.nice_name).to eq('Facebook')
    end
  end

end
