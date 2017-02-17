module ClientsHelper

  def name(client_channel)
    client_channel.class.name.split('::').last
  end

  def uid_field(client_channel)
    client_channel.class.name.split('::').last + 'UID'
  end
end
