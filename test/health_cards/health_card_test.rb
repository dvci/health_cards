# frozen_string_literal: true

require 'test_helper'

class HealthCardTest < ActiveSupport::TestCase
  setup do
    @vc = vc
    @private_key = private_key
    @wrong_key = private_key
    # from https://smarthealth.cards/examples/example-00-d-jws.txt

    @jws_string = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjNLZmRnLVh3UC03Z1h5eXd0VWZVQUR3QnVtRE9QS01ReC1pRUxMMT'\
    'FXOXMifQ.3VJNj9owEP0raPYKSRy2BXJqoVI_VFWVuu2l4mCcgbjyR2Q7AbrKf-_YwLaVFi69FXFx5s2b997MI0jvoYImhNZXee41d6FBrkKTCe5'\
    'qn-OB61ahzwnYoYMxmM0WKvaSzeZsxu4X2Xw6HUMvoHqEV8KagIcA1fcnyv1-n-2nmXW7vCzYPBcOazRBcuXznsF6DOHYYuz4hk5uJd8oXD1haN5'\
    'VbXenxyQ-buKk1p2RP3mQ1twECtvLmi2iqN8yv3SbHyhC9LdtpCOVPvJUcJ8VGSO--HXZmVphxDj0tnMCH5IrOBcuLkFYpYjtpIQGuCNZJ-ZOqa9'\
    'OEeDSXxUEuDyeIf5Mdqg_LoRrPJFwLRXxwWtDGOfTjJ3s0cR4P9gmvpcZrAcyuENT0z4r0Dzp20gK4w0PkZstXrBJwSZlAcMwflYdu63u_d-R-8B'\
    'D55P9eE0B48J6LoQ0uLJ1YhC2lmaXjPijD6jPd0mbatQsHVBMOveyzkV_IAKROqEsZjCshzG050iSnC06NFHbn4kSyArRuVSKZh-kPlGUyXARbSk'\
    'bPnV6k8L5aMPorki_WKJUt9bpWCKZXATr4rRa-lbxlPxyNXqLBh1Xo3fWtzLQDQ-k7kqM5X8ZY7m4HuPs32Kk_zD8Ag.8GFVc4UsQoKJ1cqjUzT2'\
    'ZS5vLpAiOx3-BZD6EgVkh1Cw8zoa1rhxYTm-swwqmeRYTjrnFgR_aG0z8CmJrk37_g'

    @jws = HealthCards::JWS.from_jws(@jws_string)
  end

  ## Constructor

  test 'HealthCard can be created from a VerifiableCredential' do
    card = HealthCards::HealthCard.new(verifiable_credential: @vc)

    assert_not_nil card.verifiable_credential
    assert_not_nil card.verifiable_credential.fhir_bundle
    assert card.verifiable_credential.fhir_bundle.is_a?(FHIR::Bundle)
  end

  test 'HealthCard can be created from a VerifiableCredential and JWS' do
    card = HealthCards::HealthCard.new(verifiable_credential: @vc, jws: @jws)
    assert_not_nil card.jws
    assert card.jws.is_a?(HealthCards::JWS)
  end

  test 'HealthCard throws an exception when the payload is not a VerifiableCredential' do
    assert_raises HealthCards::InvalidPayloadException do
      HealthCards::HealthCard.new(verifiable_credential: FHIR::Patient.new)
    end

    assert_raises HealthCards::InvalidPayloadException do
      HealthCards::HealthCard.new(verifiable_credential: '{"foo": "bar"}')
    end

    assert_raises HealthCards::InvalidPayloadException do
      HealthCards::HealthCard.new(verifiable_credential: 'foo')
    end
  end

  ## Saving as a file

  test 'Health Card can be saved to a file' do
    file_name = './example.smart-health-card'
    health_card = HealthCards::HealthCard.new(verifiable_credential: @vc, jws: @jws)
    health_card.save_to_file(file_name)
    assert File.file?(file_name)
    File.delete(file_name)
  end

  ## Save as a QR Code

  test 'Health Card can be saved as a QR Code' do
    skip('Save as QR Code not implemented')
    file_name = './example-qr.svg'
    health_card = HealthCards::HealthCard.new(verifiable_credential: @vc, key: @private_key)
    health_card.save_as_qr_code('./example-qr.svg')
    assert File.file?(file_name)
    File.delete(file_name)
  end

  ## Creating a HealthCard from a JWS

  test 'Health Cards can be created from a JWS' do
    card = HealthCards::HealthCard.from_jws(@jws_string)
    assert_not_nil card.verifiable_credential
    assert_not_nil card.verifiable_credential.fhir_bundle
    assert card.verifiable_credential.fhir_bundle.is_a?(FHIR::Bundle)
  end

  test 'Health Card can be round tripped from Health Card to JWS and then back' do
    health_card = rails_issuer.create_health_card(@vc.fhir_bundle)
    new_health_card = HealthCards::HealthCard.from_jws(health_card.jws.to_s)

    new_vc = new_health_card.verifiable_credential

    assert_equal @vc.issuer, new_health_card.verifiable_credential.issuer
    assert_equal @vc.fhir_bundle.entry.length, new_vc.fhir_bundle.entry.length
  end
end
