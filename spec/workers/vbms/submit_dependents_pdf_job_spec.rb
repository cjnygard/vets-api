# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VBMS::SubmitDependentsPDFJob do
  let(:dependency_claim) { create(:dependency_claim_no_vet_information) }
  let(:vet_info) do
    {
      'veteran_information' => {
        'birth_date' => '1809-02-12',
        'full_name' => {
          'first' => 'WESLEY', 'last' => 'FORD', 'middle' => nil
        },
        'ssn' => '796043735',
        'va_file_number' => '796043735'
      }
    }
  end

  describe '#perform' do
    context 'with a valid submission' do
      it 'creates a PDF' do
        expect_any_instance_of(SavedClaim::DependencyClaim).to receive(:format_and_upload_pdf).with(
          vet_info
        )

        described_class.new.perform(dependency_claim.id, vet_info)
      end
    end

    context 'with an invalid submission' do
      it 'sends an error message if no claim exists' do
        job = described_class.new

        expect(job).to receive(:send_error_to_sentry).with(
          anything,
          nil
        )

        job.perform('non-existant-claim', vet_info)
      end

      it 'returns false' do
        job = described_class.new.perform('f', vet_info)

        expect(job).to eq(false)
      end
    end
  end
end
