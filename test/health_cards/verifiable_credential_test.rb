# frozen_string_literal: true
require 'test_helper'
require 'health_cards/verifiable_credential'

class VerifiableCredentialTest < ActiveSupport::TestCase
  setup do
    @bundle = { resourceType: 'Bundle' }
  end

  test 'with subject identified' do
    @subject = 'foo'
    @vc = HealthCards::VerifiableCredential.new(@bundle, @subject)

    assert_equal @vc.credential.dig(:credentialSubject, :fhirBundle), @bundle
    assert_equal @vc.credential.dig(:credentialSubject, :id), @subject
  end

  test 'without subject identifier' do
    @vc = HealthCards::VerifiableCredential.new(@bundle)
    assert_equal @vc.credential.dig(:credentialSubject, :fhirBundle), @bundle
    assert_nil @vc.credential.dig(:credentialSubject, :id)
  end


end