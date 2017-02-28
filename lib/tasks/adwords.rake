namespace :adwords do
  task :setup_oauth => :environment do
    begin
      authentication_hash = AppConfig.adwords.slice(:oauth2_client_id, :oauth2_client_secret, :developer_token)
      adwords = AdwordsApi::Api.new({authentication: authentication_hash})

      token = adwords.authorize() do |auth_url|
        puts "Hit Auth error, please navigate to URL:\n\t%s" % auth_url
        print 'log in and type the verification code: '
        verification_code = STDIN.gets.chomp
        verification_code
      end
      if token
        puts token
      end
    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

    # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
    end

    end
end
