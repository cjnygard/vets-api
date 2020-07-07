# frozen_string_literal: true

module BGS
  class DependentService
    def get_dependents(current_user)
      service = BGS::Services.new(
        external_uid: current_user.icn,
        external_key: current_user.common_name
      )

      service.claimants.find_dependents_by_participant_id(current_user.participant_id, current_user.ssn)
    end
  end
end
