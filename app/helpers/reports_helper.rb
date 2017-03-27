module ReportsHelper

  def from_date(report)
    name_array =  report.title.split('_')
    return Date.parse(name_array[name_array.length - 2])
  end

  def to_date(report)
    name_array =  report.title.split('_')
    return Date.parse(name_array[name_array.length - 1].split('.').first)
  end

  def estimated_download_time(report)
    cc = report.client_channel.nice_name
    case cc
    when 'Adwords'
      '90 mins'
    when 'Facebook'
      '2-5 mins'
    when 'Instagram'
      '2-5 mins'
    when 'Twitter'
      '5-7 mins'
    end
  end
end
