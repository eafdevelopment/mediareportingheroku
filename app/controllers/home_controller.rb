# Home index is the landing page with report search form

class HomeController < ApplicationController

  def index

    # >> Testing twitter
    dmu_intl = Client.find_by(name: 'DMU International - eight&four')
    dmu_twitter = ClientChannel.find_by(type: 'ClientChannels::Twitter', uid: '18ce53uuays', client_id: dmu_intl.id)
    dmu_twitter.generate_report_all_campaigns('2017-03-12', '2017-03-12')

    @clients = Client.all.order(name: :desc)
  end
  
end
