class V3::ServiceSerializer < ApplicationSerializer

  attributes :id, :name, :url, :obsoleted_service_name, :product

  has_one :product, serializer: V3::ProductSerializer

  def url
    # credentials parameter is required by Yast, it dies without it
    "plugin:/susecloud?credentials=#{object.name}&url=" + service_url(object, host: base_url)
  end

  def obsoleted_service_name
    instance_options[:obsoleted_service_name] || ''
  end

end
