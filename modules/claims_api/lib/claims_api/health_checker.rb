# frozen_string_literal: true

module ClaimsApi
  class HealthChecker
    BGS_WSDL = "#{Settings.bgs.url}/VetRecordServiceBean/VetRecordWebService?WSDL"

    def self.services_are_healthy?
      # TODO: we should add check for Okta and SAML Proxies being up as well
      mvi_is_healthy? && evss_is_healthy? && bgs_is_healthy? && vbms_is_healthy?
    end

    def self.evss_is_healthy?
      EVSS::Service.service_is_up?
    end

    def self.mvi_is_healthy?
      MPI::Service.service_is_up?
    end

    def self.bgs_is_healthy?
      # response = Faraday.get(BGS_WSDL)
      # response.status == 200
      # BGS does not have upper level access yet, just return true
      true
    end

    def self.vbms_is_healthy?
      # response = Faraday.get(Settings.vbms.url)
      # response.status == 200
      # VBMS does not have upper level access yet, just return true
      true
    end
  end
end
