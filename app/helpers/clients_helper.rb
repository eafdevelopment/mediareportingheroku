module ClientsHelper

  def uid_field(client_channel)
    client_channel.class.name.split('::').last + 'UID'
  end
end
