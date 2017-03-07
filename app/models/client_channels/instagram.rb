class ClientChannels::Instagram < ClientChannels::Facebook

  # All methods inherited from ClientChannels::Facebook
  
  def parse_instagram_insights(insights, headers)
    rows = { data: [] }
    insights.each do |campaign_insights|
      campaign = FacebookAds::AdCampaign.find(campaign_insights[0])

      # Exclude FB campaigns from the Instagram report
      if campaign.ad_sets && campaign.ad_sets.first && campaign.ad_sets.first.targeting['publisher_platforms'].include?('instagram')
        # Insights ordered by campaign and date_start
        insights_ordered_by_date = campaign_insights[1].group_by(&:date_start)
        insights_ordered_by_date.each do |day_insights|
          # Instagram metrics for single row (one campaign, one day)
          insta_row = make_row(headers, day_insights)
          # GA metrics for single row (one campaign, one day)
          ga_row = GoogleAnalytics.fetch_and_parse_metrics(insta_row.first, insta_row.first, self.client.google_analytics_view_id, campaign.name)
          # Create row of FB & GA campaign metrics if there are any
          ga_row[:data_rows].any? ? campaign_row = insta_row.concat(ga_row[:data_rows].first) : campaign_row = insta_row

          rows[:data].push(insta_row)
        end
      end
    end
    return rows
  end

end