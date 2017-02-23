module ApplicationHelper

  def name(client_channel)
    client_channel.class.name.split('::').last
  end
  
end
