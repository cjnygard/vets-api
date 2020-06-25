# frozen_string_literal: true

require 'facilities/ppms/client'

class V0::Facilities::CcpController < FacilitiesController
  before_action :validate_id, only: [:show]

  def index
    raise Common::Exceptions::ParameterMissing.new('type', detail: TYPE_SERVICE_ERR) if params[:type].nil?

    ppms_results =  case search_params[:type]
                    when 'cc_provider'
                      provider_search
                    when 'cc_pharmacy'
                      provider_search('services' => ['3336C0003X'])
                    when 'cc_urgent_care'
                      api.pos_locator(search_params)
                    end

    render  json: ppms_results,
            each_serializer: ProviderSerializer,
            meta: { pagination: pages(ppms_results) }
  end

  def show
    result = api.provider_info(params[:id])
    raise Common::Exceptions::RecordNotFound, params[:id] if result.nil?

    services = api.provider_services(params[:id])
    result.add_provider_service(services[0]) if services.present?
    render json: result, serializer: ProviderSerializer
  end

  def services
    result = api.specialties
    render json: result
  end

  private

  def search_params
    params.permit(:type, :address, :page, :per_page, services: [], bbox: [])
  end

  def provider_search(options = {})
    api.provider_locator(search_params.merge(options)).map do |provider|
      prov_info = api.provider_info(provider['ProviderIdentifier'])
      provider.add_details(prov_info)
      provider
    end
  end

  def api
    @api ||= Facilities::PPMS::Client.new
  end

  def per_page
    Integer(search_params[:per_page] || BaseFacility.per_page)
  end

  def page
    Integer(search_params[:page] || 1)
  end

  def pages(_ppms_results)
    total = (page + 1) * per_page
    {
      current_page: page,
      per_page: per_page,
      total_pages: page + 1,
      total_entries: total
    }
  end

  def validate_id
    if /^ccp_/.match?(params[:id])
      params[:id] = params[:id].sub(/^ccp_/, '')
    else
      raise Common::Exceptions::InvalidFieldValue.new('id', params[:id])
    end
  end
end
