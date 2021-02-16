# frozen_string_literal: true

require 'test_helper'

describe HealthCards::VerifiableCredential do
  before do
    @bundle = { resourceType: 'Bundle' }
  end
  describe 'when a subject identifier is provided' do
    before do
      @subject = 'foo'
      @vc = HealthCards::VerifiableCredential.new(@bundle, @subject)
    end

    describe 'when asked for the verifiable credential' do
      it 'must include the bundle' do
        _(@vc.credential.dig(:credentialSubject, :fhirBundle)).must_equal @bundle
      end

      it 'must provide a credentialSubject id' do
        _(@vc.credential.dig(:credentialSubject, :id)).must_equal @subject
      end
    end
  end
  describe 'when a subject identifier is not provided' do
    before do
      @vc = HealthCards::VerifiableCredential.new(@bundle)
    end

    describe 'when asked for the verifiable credential' do
      it 'must include the bundle' do
        _(@vc.credential.dig(:credentialSubject, :fhirBundle)).must_equal @bundle
      end

      it 'must not provide a credentialSubject id' do
        _(@vc.credential.dig(:credentialSubject, :id)).must_be_nil
      end
    end
  end
end
