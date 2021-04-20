# frozen_string_literal: true

require 'test_helper'

class HealthCardTest < ActiveSupport::TestCase
  setup do
    @bundle = bundle_payload
    @private_key = private_key
    @wrong_key = private_key
    # from https://smarthealth.cards/examples/example-00-d-jws.txt
    @example_jws = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjNLZmRnLVh3UC03Z1h5eXd0VWZVQUR3QnVtRE9QS01ReC1pRUxMMTFXOXMifQ.3VJNj9owEP0raPYKSRy2BXJqoVI_VFWVuu2l4mCcgbjyR2Q7AbrKf-_YwLaVFi69FXFx5s2b997MI0jvoYImhNZXee41d6FBrkKTCe5qn-OB61ahzwnYoYMxmM0WKvaSzeZsxu4X2Xw6HUMvoHqEV8KagIcA1fcnyv1-n-2nmXW7vCzYPBcOazRBcuXznsF6DOHYYuz4hk5uJd8oXD1haN5VbXenxyQ-buKk1p2RP3mQ1twECtvLmi2iqN8yv3SbHyhC9LdtpCOVPvJUcJ8VGSO--HXZmVphxDj0tnMCH5IrOBcuLkFYpYjtpIQGuCNZJ-ZOqa9OEeDSXxUEuDyeIf5Mdqg_LoRrPJFwLRXxwWtDGOfTjJ3s0cR4P9gmvpcZrAcyuENT0z4r0Dzp20gK4w0PkZstXrBJwSZlAcMwflYdu63u_d-R-8BD55P9eE0B48J6LoQ0uLJ1YhC2lmaXjPijD6jPd0mbatQsHVBMOveyzkV_IAKROqEsZjCshzG050iSnC06NFHbn4kSyArRuVSKZh-kPlGUyXARbSkbPnV6k8L5aMPorki_WKJUt9bpWCKZXATr4rRa-lbxlPxyNXqLBh1Xo3fWtzLQDQ-k7kqM5X8ZY7m4HuPs32Kk_zD8Ag.8GFVc4UsQoKJ1cqjUzT2ZS5vLpAiOx3-BZD6EgVkh1Cw8zoa1rhxYTm-swwqmeRYTjrnFgR_aG0z8CmJrk37_g'
  end

  ## Constructor

  test 'HealthCard can be created from a FHIR Bundle model' do
    HealthCards::HealthCard.new(payload: @bundle)
  end

  test 'HealthCard can be created from a FHIR Bundle as a JSON string' do
    HealthCards::HealthCard.new(payload: @bundle.to_json)
  end

  test 'HealthCard throws an exception when the payload is not a FHIR Bundle' do
    assert_raises HealthCards::HealthCard::InvalidPayloadException do
      HealthCards::HealthCard.new(payload: FHIR::Patient.new)
    end

    assert_raises HealthCards::HealthCard::InvalidPayloadException do
      HealthCards::HealthCard.new(payload: '{"foo": "bar"}')
    end

    assert_raises HealthCards::HealthCard::InvalidPayloadException do
      HealthCards::HealthCard.new(payload: 'foo')
    end
  end

  ## Adding and Removing Keys

  test 'HealthCard allows private keys to be added' do
    health_card = HealthCards::HealthCard.new
    assert_nil health_card.key
    health_card.key= @private_key
    assert_not_nil health_card.key
    assert_includes health_card.key, @private_key
  end

  test 'HealthCard allows private keys to be removed' do
    health_card = HealthCards::HealthCard.new(key: @private_key)
    assert health_card.key
    assert_equal health_card.key, @private_key
    health_card.key = nil
    assert_nil health_card.key
  end

  test 'HealthCard allows public keys to be added' do
    health_card = HealthCards::HealthCard.new
    assert_nil health_card.public_key
    health_card.public_key= @public_key
    assert_not_nil health_card.public_key
    assert_equal health_card.public_key, @public_key
  end

  test 'HealthCard allows public keys to be removed' do
    health_card = HealthCards::HealthCard.new(public_key: @public_key)
    assert health_card.public_key
    assert_includes health_card.public_key, @public_key
    health_card.public_key = nil
    assert_nil health_card.public_key
  end

  ## JWS Encoding

  test 'Health Card can be encoded as a JWS' do
    health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key)
    jws = health_card.to_jws
    assert_equal 3, jws.split('.').length
  end

  test 'Health Card throws an exception when attempting to encode as a JWS without private key' do
    assert_raises HealthCards::MissingPrivateKey do
      health_card = HealthCards::HealthCard.new(payload: @bundle)
      jws = health_card.to_jws
      assert_equal 3, jws.split('.').length
    end
  end

  test 'HealthCard throws an exception when attempting to encode as a JWS with only a public key' do
    assert_raises HealthCards::MissingPrivateKey do
      health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key.public_key)
      jws = health_card.to_jws
      assert_equal 3, jws.split('.').length
    end
  end

  ## Saving as a file

  test 'Health Card can be saved to a file' do
    file_name = './example.smart-health-card'
    health_card = HealthCards::HealthCard.new(payload: @bundle, private_key: @private_key)
    health_card.save_to_file(file_name)
    assert File.file?(file_name)
    File.delete(file_name)
  end

  ## Save as a QR Code

  test 'Health Card can be saved as a QR Code' do
    skip('Save as QR Code not implemented')
    file_name = './example-qr.svg'
    health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key)
    health_card.save_as_qr_code('./example-qr.svg')
    assert File.file?(file_name)
    File.delete(file_name)
  end

  ## Health Card Verification

  test 'Health Cards can be verified when a private key is loaded' do
    health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key)
    assert health_card.verify
  end

  test 'Health Cards can be verified when only a public key is loaded' do
    health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key)
    health_card.to_jws # Call `to_jws` while the private key is around to generate the signature
    health_card.key = nil # remove the private key
    assert health_card.verify
  end

  test 'Health Cards throws an exception when trying to verify without a key' do
    assert_raises HealthCards::MissingPublicKey do
      health_card = HealthCards::HealthCard.new(payload: @bundle)
      assert health_card.verify
    end
  end

  test 'HealthCard can verify JWS when key is resolvable' do
    stub_request(:get, /jwks.json/).to_return(body: @private_key.public_key.to_jwk)
    health_card = HealthCards::HealthCard.new(payload: @bundle)
    assert health_card.verify
  end

  ## Creating a HealthCard from a JWS

  test 'Health Cards can be created from a JWS' do
    skip('Need to add Verifiable Credential compression/decompression')
    health_card = HealthCards::HealthCard.from_jws(@jws)
    assert health_card
    #TODO: Better checks here
  end

  test 'Health Card can be round tripped from Health Card to JWS and then back' do
    health_card = HealthCards::HealthCard.new(payload: @bundle, key: @private_key)
    jws = health_card.to_jws
    new_health_card = HealthCards::HealthCard.from_jws(jws)
    assert new_health_card
  end

  ## Key Resolution

  test 'Health Cards key resolution is active by default' do
    skip('Key resolution not implemented')
    assert HealthCards::HealthCard.new.globally_resolve_keys?
  end

  test 'Health Cards key resolution can be disabled' do
    skip('Key resolution not implemented')
    health_card = HealthCards::HealthCard.new
    assert health_card.resolve_keys?
    health_card.resolve_keys = false
    assert_not health_card.resolve_keys?
    health_card.resolve_keys = true
  end

  test 'Health Cards will not verify health cards when key is not resolvable' do
    skip('Key resolution not implemented')
    stub_request(:get, /jwks.json/).to_return(body: @private_key.public_key.to_jwk)
    health_card = HealthCards::HealthCard.new(payload: @bundle)
    health_card.resolve_keys = false
    assert_raises HealthCards::MissingPublicKey do
      health_card.verify
    end
    health_card.resolve_keys = true
    assert health_card.verify
  end

  test 'Health Cards class key resolution is active by default' do
    skip('Key resolution not implemented')
    assert HealthCards::HealthCard.globally_resolve_keys?
  end

  test 'Health Cards class key resolution can be disabled' do
    skip('Key resolution not implemented')
    health_card = HealthCards::HealthCard
    assert health_card.globally_resolve_keys?
    health_card.globally_resolve_keys = false
    assert_not health_card.globally_resolve_keys?
    health_card.globally_resolve_keys = true
  end

  test 'Health Cards class will not verify health cards when key is not resolvable with global resolution off' do
    skip('Key resolution not implemented')
    stub_request(:get, /jwks.json/).to_return(body: @public_key.to_jwk)
    health_card = HealthCards::HealthCard.new(payload: @bundle)
    health_card.globally_resolve_keys = false
    assert_raises HealthCards::MissingPublicKey do
      health_card.verify
    end
    health_card.globally_resolve_keys = true
    assert health_card.verify
  end
end
