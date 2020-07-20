# frozen_string_literal: true

module V0
  # Application for the Program of Comprehensive Assistance for Family Caregivers (Form 10-10CG)
  class CaregiversAssistanceClaimsController < ApplicationController
    skip_before_action(:authenticate)

    rescue_from ::Form1010cg::Service::InvalidVeteranStatus, with: :backend_service_outage

    def create
      increment Form1010cg::Service.metrics.attempt
      return service_unavailable unless Flipper.enabled?(:allow_online_10_10cg_submissions)

      claim = SavedClaim::CaregiversAssistanceClaim.new(form: form_submission)

      if claim.valid?
        submission = ::Form1010cg::Service.new(claim).process_claim!
        increment Form1010cg::Service.metrics.success
        render json: submission, serializer: ::Form1010cg::SubmissionSerializer
      else
        increment Form1010cg::Service.metrics.failure.client.data
        raise(Common::Exceptions::ValidationErrors, claim)
      end
    end

    # If we were unable to submit the user's claim digitally, we allow them to the download
    # the 10-10CG PDF, pre-filled with their data, for them to mail in.
    def download_pdf
      claim = SavedClaim::CaregiversAssistanceClaim.new(form: form_submission)

      if claim.valid?
        filename  = file_name_for_pdf(claim.veteran_data)
        file_path = claim.to_pdf

        send_file "#{Rails.root}/#{file_path}", filename: filename, type: 'application/pdf'
      else
        raise(Common::Exceptions::ValidationErrors, claim)
      end
    end

    private

    def file_name_for_pdf(veteran_data)
      "10-10CG_#{veteran_data['fullName']['first']}_#{veteran_data['fullName']['last']}.pdf"
    end

    def form_submission
      params.require(:caregivers_assistance_claim).require(:form)
    rescue
      increment Form1010cg::Service.metrics.failure.client.data
      raise
    end

    def service_unavailable
      render nothing: true, status: :service_unavailable, as: :json
    end

    def backend_service_outage
      increment Form1010cg::Service.metrics.failure.client.qualification
      render_errors Common::Exceptions::ServiceOutage.new(nil, detail: 'Backend Service Outage')
    end

    def increment(stat)
      StatsD.increment stat
    end
  end
end
