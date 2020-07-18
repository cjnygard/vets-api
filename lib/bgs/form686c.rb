# frozen_string_literal: true

module BGS
  class Form686c < Service
    def initialize(user)
      @user = user.with_indifferent_access
    end

    def submit(payload)
      proc_id = create_proc_id_and_form
      veteran = VnpVeteran.new(proc_id: proc_id, payload: payload, user: @user).create

      dependents = Dependents.new(proc_id: proc_id, payload: payload, user: @user).create
      VnpRelationships.new(proc_id: proc_id, veteran: veteran, dependents: dependents, user: @user).create

      dependents.each do |dependent|
        if dependent[:type] == '674'
          StudentSchool.new(proc_id: proc_id, vnp_participant_id: dependent[:vnp_participant_id], payload: payload, user: @user).create
        end
      end

      vnp_benefit_claim = VnpBenefitClaim.new(proc_id: proc_id, veteran: veteran, user: @user)
      vnp_benefit_claim_record = vnp_benefit_claim.create

      benefit_claim_record = BenefitClaim.new(vnp_benefit_claim: vnp_benefit_claim_record, veteran: veteran, user: @user).create
      vnp_benefit_claim.update(benefit_claim_record, vnp_benefit_claim_record)
      update_proc(proc_id)
    end

    private

    def create_proc_id_and_form
      vnp_response = create_proc
      create_proc_form(vnp_response[:vnp_proc_id])

      vnp_response[:vnp_proc_id]
    end
  end
end