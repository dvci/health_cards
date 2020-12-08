# frozen_string_literal: true

require 'test_helper'
require 'minitest/spec'

describe HealthCards::VerifiableCredential do
  before do
    @bundle = { resourceType: 'Bundle' }
    @vc = HealthCards::VerifiableCredential.new({ resourceType: 'Bundle' })
  end

  describe 'when asked for the verifiable credential' do
    it 'must include the bundle' do
      _(@vc.credential.dig(:credentialSubject, :fhirBundle)).must_equal @bundle
    end
  end
end
